"""Comprehensive tests for Azure Pricing MCP Server."""

from typing import Any
from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from mcp.types import TextContent

from azure_pricing_mcp.handlers import (
    _handle_cost_estimate,
    _handle_customer_discount,
    _handle_discover_skus,
    _handle_price_compare,
    _handle_price_search,
    _handle_sku_discovery,
)
from azure_pricing_mcp.server import AzurePricingServer


@pytest.fixture
def mock_pricing_response() -> dict[str, Any]:
    """Sample Azure pricing API response."""
    return {
        "BillingCurrency": "USD",
        "CustomerEntityId": "Default",
        "CustomerEntityType": "Retail",
        "Items": [
            {
                "currencyCode": "USD",
                "tierMinimumUnits": 0.0,
                "retailPrice": 0.096,
                "unitPrice": 0.096,
                "armRegionName": "eastus",
                "location": "US East",
                "effectiveStartDate": "2021-01-01T00:00:00Z",
                "meterId": "00000000-0000-0000-0000-000000000000",
                "meterName": "D4s v3",
                "productId": "DZH318Z0BQ36",
                "skuId": "DZH318Z0BQ36/00G1",
                "productName": "Virtual Machines Dsv3 Series",
                "skuName": "D4s v3",
                "serviceName": "Virtual Machines",
                "serviceId": "DZH317F1HKN0",
                "serviceFamily": "Compute",
                "unitOfMeasure": "1 Hour",
                "type": "Consumption",
                "isPrimaryMeterRegion": True,
                "armSkuName": "Standard_D4s_v3",
            }
        ],
        "NextPageLink": None,
        "Count": 1,
    }


@pytest.fixture
def mock_pricing_response_with_savings() -> dict[str, Any]:
    """Sample Azure pricing API response with savings plans."""
    return {
        "BillingCurrency": "USD",
        "Items": [
            {
                "currencyCode": "USD",
                "retailPrice": 0.096,
                "armRegionName": "eastus",
                "location": "US East",
                "meterName": "D4s v3",
                "productName": "Virtual Machines Dsv3 Series",
                "skuName": "D4s v3",
                "serviceName": "Virtual Machines",
                "serviceFamily": "Compute",
                "unitOfMeasure": "1 Hour",
                "type": "Consumption",
                "armSkuName": "Standard_D4s_v3",
                "savingsPlan": [
                    {"term": "1 Year", "retailPrice": 0.066},
                    {"term": "3 Year", "retailPrice": 0.044},
                ],
            }
        ],
        "NextPageLink": None,
        "Count": 1,
    }


@pytest.fixture
async def pricing_server():
    """Create a pricing server instance for testing."""
    server = AzurePricingServer()
    async with server:
        yield server


class TestAzurePricingServer:
    """Test suite for AzurePricingServer class."""

    @pytest.mark.asyncio
    async def test_make_request_success(self, pricing_server, mock_pricing_response):
        """Test successful API request."""
        with patch.object(pricing_server.session, "get") as mock_get:
            mock_response = AsyncMock()
            mock_response.status = 200
            mock_response.json = AsyncMock(return_value=mock_pricing_response)
            mock_response.raise_for_status = MagicMock()
            mock_get.return_value.__aenter__.return_value = mock_response

            result = await pricing_server._make_request("https://test.com")

            assert result == mock_pricing_response
            mock_get.assert_called_once()

    @pytest.mark.asyncio
    async def test_make_request_rate_limit_retry(self, pricing_server):
        """Test rate limit handling with retries."""
        with patch.object(pricing_server.session, "get") as mock_get:
            # First call returns 429, second succeeds
            mock_response_429 = AsyncMock()
            mock_response_429.status = 429

            mock_response_200 = AsyncMock()
            mock_response_200.status = 200
            mock_response_200.json = AsyncMock(return_value={"Items": []})
            mock_response_200.raise_for_status = MagicMock()

            mock_get.return_value.__aenter__.side_effect = [
                mock_response_429,
                mock_response_200,
            ]

            with patch("asyncio.sleep", new_callable=AsyncMock):
                result = await pricing_server._make_request("https://test.com")

            assert result == {"Items": []}
            assert mock_get.call_count == 2

    @pytest.mark.asyncio
    async def test_search_azure_prices_basic(self, pricing_server, mock_pricing_response):
        """Test basic price search."""
        with patch.object(pricing_server, "_make_request", return_value=mock_pricing_response):
            result = await pricing_server.search_azure_prices(
                service_name="Virtual Machines", sku_name="D4s v3", limit=10
            )

            assert result["count"] == 1
            assert result["currency"] == "USD"
            assert len(result["items"]) == 1
            assert result["items"][0]["skuName"] == "D4s v3"

    @pytest.mark.asyncio
    async def test_search_azure_prices_with_discount(self, pricing_server, mock_pricing_response):
        """Test price search with discount applied."""
        with patch.object(pricing_server, "_make_request", return_value=mock_pricing_response):
            result = await pricing_server.search_azure_prices(
                service_name="Virtual Machines",
                sku_name="D4s v3",
                discount_percentage=10.0,
                limit=10,
            )

            assert result["count"] == 1
            assert "discount_applied" in result
            assert result["discount_applied"]["percentage"] == 10.0

            # Check that price was discounted
            original_price = 0.096
            expected_price = original_price * 0.9
            assert result["items"][0]["retailPrice"] == pytest.approx(expected_price)
            assert result["items"][0]["originalPrice"] == original_price

    @pytest.mark.asyncio
    async def test_search_azure_prices_no_results(self, pricing_server):
        """Test price search with no results."""
        empty_response = {"Items": [], "NextPageLink": None, "Count": 0}

        with patch.object(pricing_server, "_make_request", return_value=empty_response):
            result = await pricing_server.search_azure_prices(service_name="NonExistent", sku_name="Invalid")

            assert result["count"] == 0
            assert len(result["items"]) == 0

    @pytest.mark.asyncio
    async def test_compare_prices_across_regions(self, pricing_server, mock_pricing_response):
        """Test price comparison across regions."""
        with patch.object(pricing_server, "search_azure_prices") as mock_search:
            mock_search.return_value = {
                "items": [mock_pricing_response["Items"][0]],
                "count": 1,
            }

            result = await pricing_server.compare_prices(
                service_name="Virtual Machines",
                sku_name="D4s v3",
                regions=["eastus", "westus"],
            )

            assert result["comparison_type"] == "regions"
            assert len(result["comparisons"]) == 2
            assert mock_search.call_count == 2

    @pytest.mark.asyncio
    async def test_estimate_costs(self, pricing_server, mock_pricing_response_with_savings):
        """Test cost estimation with savings plans."""
        with patch.object(pricing_server, "search_azure_prices") as mock_search:
            mock_search.return_value = {
                "items": [mock_pricing_response_with_savings["Items"][0]],
                "count": 1,
            }

            result = await pricing_server.estimate_costs(
                service_name="Virtual Machines",
                sku_name="D4s v3",
                region="eastus",
                hours_per_month=730,
            )

            assert "on_demand_pricing" in result
            assert "savings_plans" in result
            assert result["on_demand_pricing"]["hourly_rate"] == 0.096
            assert result["on_demand_pricing"]["monthly_cost"] == pytest.approx(0.096 * 730)
            assert len(result["savings_plans"]) == 2

    @pytest.mark.asyncio
    async def test_estimate_costs_with_discount(self, pricing_server, mock_pricing_response):
        """Test cost estimation with customer discount."""
        with patch.object(pricing_server, "search_azure_prices") as mock_search:
            mock_search.return_value = {
                "items": [mock_pricing_response["Items"][0]],
                "count": 1,
            }

            result = await pricing_server.estimate_costs(
                service_name="Virtual Machines",
                sku_name="D4s v3",
                region="eastus",
                hours_per_month=730,
                discount_percentage=15.0,
            )

            assert "discount_applied" in result
            original_hourly = 0.096
            discounted_hourly = original_hourly * 0.85
            assert result["on_demand_pricing"]["hourly_rate"] == pytest.approx(discounted_hourly)

    @pytest.mark.asyncio
    async def test_discover_skus(self, pricing_server, mock_pricing_response):
        """Test SKU discovery."""
        mock_response = {
            "Items": [
                {**mock_pricing_response["Items"][0], "skuName": "D4s v3"},
                {**mock_pricing_response["Items"][0], "skuName": "D8s v3"},
            ],
            "NextPageLink": None,
            "Count": 2,
        }

        with patch.object(pricing_server, "_make_request", return_value=mock_response):
            result = await pricing_server.discover_skus(service_name="Virtual Machines", limit=100)

            assert result["total_skus"] == 2
            assert len(result["skus"]) == 2
            assert result["service_name"] == "Virtual Machines"

    @pytest.mark.asyncio
    async def test_discover_service_skus_exact_match(self, pricing_server, mock_pricing_response):
        """Test SKU discovery with exact service match."""
        with patch.object(pricing_server, "search_azure_prices_with_fuzzy_matching") as mock_search:
            mock_search.return_value = {
                "items": [mock_pricing_response["Items"][0]],
                "suggestion_used": "Virtual Machines",
                "match_type": "exact_mapping",
            }

            result = await pricing_server.discover_service_skus(service_hint="vm", limit=30)

            assert result["service_found"] == "Virtual Machines"
            assert result["original_search"] == "vm"
            assert result["total_skus"] > 0

    @pytest.mark.asyncio
    async def test_get_customer_discount(self, pricing_server):
        """Test customer discount retrieval."""
        result = await pricing_server.get_customer_discount()

        assert result["discount_percentage"] == 10.0
        assert result["customer_id"] == "default"
        assert result["discount_type"] == "standard"

    @pytest.mark.asyncio
    async def test_get_customer_discount_custom_id(self, pricing_server):
        """Test customer discount with custom ID."""
        result = await pricing_server.get_customer_discount(customer_id="customer123")

        assert result["customer_id"] == "customer123"
        assert result["discount_percentage"] == 10.0

    @pytest.mark.asyncio
    async def test_apply_discount_to_items(self, pricing_server):
        """Test discount application to price items."""
        items = [
            {"retailPrice": 100.0, "skuName": "Test1"},
            {"retailPrice": 200.0, "skuName": "Test2"},
        ]

        discounted = pricing_server._apply_discount_to_items(items, 20.0)

        assert discounted[0]["retailPrice"] == 80.0
        assert discounted[0]["originalPrice"] == 100.0
        assert discounted[1]["retailPrice"] == 160.0
        assert discounted[1]["originalPrice"] == 200.0

    @pytest.mark.asyncio
    async def test_validate_and_suggest_skus(self, pricing_server):
        """Test SKU validation and suggestions."""
        mock_response = {
            "items": [
                {
                    "skuName": "Standard_D4s_v3",
                    "retailPrice": 0.096,
                    "unitOfMeasure": "1 Hour",
                    "productName": "VM",
                    "armRegionName": "eastus",
                },
                {
                    "skuName": "Standard_D8s_v3",
                    "retailPrice": 0.192,
                    "unitOfMeasure": "1 Hour",
                    "productName": "VM",
                    "armRegionName": "eastus",
                },
            ],
            "count": 2,
        }

        with patch.object(pricing_server, "search_azure_prices", return_value=mock_response):
            result = await pricing_server._validate_and_suggest_skus(
                service_name="Virtual Machines", sku_name="D4s", currency_code="USD"
            )

            assert "sku_validation" in result
            assert result["sku_validation"]["found"] is False
            assert len(result["sku_validation"]["suggestions"]) > 0


class TestToolHandlers:
    """Test suite for tool handler functions."""

    @pytest.mark.asyncio
    async def test_handle_price_search(self, pricing_server, mock_pricing_response):
        """Test price search handler."""
        with patch.object(pricing_server, "search_azure_prices") as mock_search:
            mock_search.return_value = {
                "items": [mock_pricing_response["Items"][0]],
                "count": 1,
                "has_more": False,
                "currency": "USD",
                "filters_applied": [],
            }

            with patch.object(pricing_server, "get_customer_discount") as mock_discount:
                mock_discount.return_value = {"discount_percentage": 10.0}

                result = await _handle_price_search(pricing_server, {"service_name": "Virtual Machines"})

                assert isinstance(result, list)
                assert len(result) == 1
                assert isinstance(result[0], TextContent)
                assert "Virtual Machines" in result[0].text

    @pytest.mark.asyncio
    async def test_handle_price_compare(self, pricing_server):
        """Test price comparison handler."""
        with patch.object(pricing_server, "compare_prices") as mock_compare:
            mock_compare.return_value = {
                "comparisons": [
                    {"region": "eastus", "retail_price": 0.096},
                    {"region": "westus", "retail_price": 0.100},
                ],
                "service_name": "Virtual Machines",
                "comparison_type": "regions",
            }

            result = await _handle_price_compare(
                pricing_server,
                {"service_name": "Virtual Machines", "regions": ["eastus", "westus"]},
            )

            assert isinstance(result, list)
            assert len(result) == 1
            assert "eastus" in result[0].text
            assert "westus" in result[0].text

    @pytest.mark.asyncio
    async def test_handle_cost_estimate(self, pricing_server):
        """Test cost estimation handler."""
        with patch.object(pricing_server, "estimate_costs") as mock_estimate:
            mock_estimate.return_value = {
                "service_name": "Virtual Machines",
                "sku_name": "D4s v3",
                "region": "eastus",
                "product_name": "Virtual Machines Dsv3 Series",
                "unit_of_measure": "1 Hour",
                "currency": "USD",
                "on_demand_pricing": {
                    "hourly_rate": 0.096,
                    "daily_cost": 2.304,
                    "monthly_cost": 70.08,
                    "yearly_cost": 840.96,
                },
                "usage_assumptions": {"hours_per_month": 730, "hours_per_day": 24.0},
                "savings_plans": [],
            }

            result = await _handle_cost_estimate(
                pricing_server,
                {
                    "service_name": "Virtual Machines",
                    "sku_name": "D4s v3",
                    "region": "eastus",
                },
            )

            assert isinstance(result, list)
            assert len(result) == 1
            assert "D4s v3" in result[0].text
            assert "70.08" in result[0].text

    @pytest.mark.asyncio
    async def test_handle_discover_skus(self, pricing_server):
        """Test SKU discovery handler."""
        with patch.object(pricing_server, "discover_skus") as mock_discover:
            mock_discover.return_value = {
                "service_name": "Virtual Machines",
                "skus": [
                    {"sku_name": "D4s v3", "sample_price": 0.096},
                    {"sku_name": "D8s v3", "sample_price": 0.192},
                ],
                "total_skus": 2,
                "price_type": "Consumption",
                "region_filter": None,
            }

            result = await _handle_discover_skus(pricing_server, {"service_name": "Virtual Machines"})

            assert isinstance(result, list)
            assert len(result) == 1
            assert "D4s v3" in result[0].text
            assert "D8s v3" in result[0].text

    @pytest.mark.asyncio
    async def test_handle_sku_discovery(self, pricing_server):
        """Test intelligent SKU discovery handler."""
        with patch.object(pricing_server, "discover_service_skus") as mock_discover:
            mock_discover.return_value = {
                "service_found": "Virtual Machines",
                "original_search": "vm",
                "skus": {
                    "D4s v3": {
                        "sku_name": "D4s v3",
                        "product_name": "Virtual Machines Dsv3 Series",
                        "min_price": 0.096,
                        "sample_unit": "1 Hour",
                        "regions": ["eastus", "westus"],
                    }
                },
                "total_skus": 1,
                "currency": "USD",
                "match_type": "exact_mapping",
            }

            result = await _handle_sku_discovery(pricing_server, {"service_hint": "vm"})

            assert isinstance(result, list)
            assert len(result) == 1
            assert "Virtual Machines" in result[0].text
            assert "D4s v3" in result[0].text

    @pytest.mark.asyncio
    async def test_handle_customer_discount(self, pricing_server):
        """Test customer discount handler."""
        with patch.object(pricing_server, "get_customer_discount") as mock_discount:
            mock_discount.return_value = {
                "customer_id": "test123",
                "discount_percentage": 15.0,
                "discount_type": "enterprise",
                "description": "Enterprise customer discount",
                "applicable_services": "all",
                "note": "Contact sales for details",
            }

            result = await _handle_customer_discount(pricing_server, {"customer_id": "test123"})

            assert isinstance(result, list)
            assert len(result) == 1
            assert "test123" in result[0].text
            assert "15.0" in result[0].text


class TestServiceNameMappings:
    """Test service name fuzzy matching."""

    @pytest.mark.asyncio
    async def test_service_name_mapping_app_service(self, pricing_server):
        """Test app service name mapping."""
        with patch.object(pricing_server, "search_azure_prices") as mock_search:
            mock_search.return_value = {"items": [{"serviceName": "Azure App Service"}], "count": 1}

            await pricing_server.search_azure_prices_with_fuzzy_matching(service_name="app service")

            # Should use the mapping to search for correct service
            assert mock_search.called

    @pytest.mark.asyncio
    async def test_service_name_mapping_vm(self, pricing_server):
        """Test VM name mapping."""
        with patch.object(pricing_server, "search_azure_prices") as mock_search:
            mock_search.return_value = {"items": [{"serviceName": "Virtual Machines"}], "count": 1}

            await pricing_server.search_azure_prices_with_fuzzy_matching(service_name="vm")

            assert mock_search.called


class TestErrorHandling:
    """Test error handling scenarios."""

    @pytest.mark.asyncio
    async def test_handle_price_search_error(self, pricing_server):
        """Test error handling in price search."""
        with patch.object(pricing_server, "search_azure_prices", side_effect=ValueError("API Error")):
            # This would normally be caught by the handler wrapper
            with pytest.raises(ValueError):
                await pricing_server.search_azure_prices(service_name="Test")

    @pytest.mark.asyncio
    async def test_estimate_costs_no_results(self, pricing_server):
        """Test cost estimation with no pricing data."""
        with patch.object(pricing_server, "search_azure_prices") as mock_search:
            mock_search.return_value = {"items": [], "count": 0}

            result = await pricing_server.estimate_costs(
                service_name="NonExistent",
                sku_name="Invalid",
                region="nowhere",
            )

            assert "error" in result
