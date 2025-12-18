"""Integration tests for Azure Pricing MCP Server.

These tests make actual API calls to Azure's pricing API.
Run with: pytest tests/test_integration.py -v
"""

import pytest

from azure_pricing_mcp.server import AzurePricingServer


@pytest.mark.integration
@pytest.mark.asyncio
async def test_real_vm_price_search():
    """Test real VM price search against Azure API."""
    async with AzurePricingServer() as server:
        result = await server.search_azure_prices(
            service_name="Virtual Machines",
            region="eastus",
            sku_name="D4s v3",
            limit=5,
        )

        assert result["count"] > 0
        assert result["currency"] == "USD"
        assert len(result["items"]) > 0

        # Verify structure of returned items
        item = result["items"][0]
        assert "skuName" in item
        assert "retailPrice" in item
        assert "armRegionName" in item


@pytest.mark.integration
@pytest.mark.asyncio
async def test_real_storage_price_search():
    """Test real storage price search."""
    async with AzurePricingServer() as server:
        result = await server.search_azure_prices(
            service_name="Storage",
            region="eastus",
            limit=10,
        )

        assert result["count"] > 0
        assert len(result["items"]) > 0


@pytest.mark.integration
@pytest.mark.asyncio
async def test_real_price_comparison():
    """Test real price comparison across regions."""
    async with AzurePricingServer() as server:
        result = await server.compare_prices(
            service_name="Virtual Machines",
            sku_name="D4s v3",
            regions=["eastus", "westus", "westeurope"],
        )

        assert len(result["comparisons"]) > 0
        assert result["comparison_type"] == "regions"


@pytest.mark.integration
@pytest.mark.asyncio
async def test_real_cost_estimate():
    """Test real cost estimation."""
    async with AzurePricingServer() as server:
        result = await server.estimate_costs(
            service_name="Virtual Machines",
            sku_name="D4s v3",
            region="eastus",
            hours_per_month=730,
        )

        assert "on_demand_pricing" in result
        assert result["on_demand_pricing"]["hourly_rate"] > 0
        assert result["on_demand_pricing"]["monthly_cost"] > 0


@pytest.mark.integration
@pytest.mark.asyncio
async def test_real_sku_discovery():
    """Test real SKU discovery."""
    async with AzurePricingServer() as server:
        result = await server.discover_skus(
            service_name="Virtual Machines",
            region="eastus",
            limit=20,
        )

        assert result["total_skus"] > 0
        assert len(result["skus"]) > 0


@pytest.mark.integration
@pytest.mark.asyncio
async def test_real_fuzzy_service_discovery():
    """Test real fuzzy service name matching."""
    async with AzurePricingServer() as server:
        result = await server.discover_service_skus(
            service_hint="app service",
            limit=10,
        )

        # Should find Azure App Service
        assert result["service_found"] is not None
        assert "App Service" in result["service_found"] or len(result.get("suggestions", [])) > 0


@pytest.mark.integration
@pytest.mark.asyncio
async def test_real_discount_application():
    """Test discount application on real data."""
    async with AzurePricingServer() as server:
        result = await server.search_azure_prices(
            service_name="Virtual Machines",
            sku_name="D4s v3",
            region="eastus",
            discount_percentage=10.0,
            limit=5,
        )

        assert "discount_applied" in result
        assert result["discount_applied"]["percentage"] == 10.0

        # Verify discount was applied to items
        if result["items"]:
            item = result["items"][0]
            assert "originalPrice" in item
            assert item["retailPrice"] < item["originalPrice"]


@pytest.mark.integration
@pytest.mark.asyncio
async def test_real_customer_discount():
    """Test customer discount retrieval."""
    async with AzurePricingServer() as server:
        result = await server.get_customer_discount()

        assert result["discount_percentage"] > 0
        assert result["customer_id"] is not None


@pytest.mark.integration
@pytest.mark.asyncio
async def test_real_invalid_sku_validation():
    """Test SKU validation with invalid SKU."""
    async with AzurePricingServer() as server:
        result = await server.search_azure_prices(
            service_name="Virtual Machines",
            sku_name="InvalidSKUName123",
            validate_sku=True,
            limit=5,
        )

        # Should provide suggestions or validation info
        assert "sku_validation" in result or result["count"] == 0


@pytest.mark.integration
@pytest.mark.asyncio
async def test_real_multiple_currencies():
    """Test pricing in different currencies."""
    async with AzurePricingServer() as server:
        currencies = ["USD", "EUR", "GBP"]

        for currency in currencies:
            result = await server.search_azure_prices(
                service_name="Virtual Machines",
                sku_name="D4s v3",
                region="eastus",
                currency_code=currency,
                limit=1,
            )

            assert result["currency"] == currency
            if result["items"]:
                assert result["items"][0]["currencyCode"] == currency


@pytest.mark.integration
@pytest.mark.asyncio
async def test_real_savings_plans():
    """Test retrieval of savings plan pricing."""
    async with AzurePricingServer() as server:
        result = await server.estimate_costs(
            service_name="Virtual Machines",
            sku_name="D4s v3",
            region="eastus",
            hours_per_month=730,
        )

        # Some VMs have savings plans
        if result.get("savings_plans"):
            assert len(result["savings_plans"]) > 0
            plan = result["savings_plans"][0]
            assert "term" in plan
            assert "hourly_rate" in plan
            assert "savings_percent" in plan
