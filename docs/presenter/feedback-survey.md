# Workshop Feedback Survey

> **Version:** 3.6.0 | **Last Updated:** 2025-01-15 | [Back to Presenter Resources](README.md)

Use this template to collect feedback after delivering Agentic InfraOps workshops.
Adapt questions based on the specific scenario delivered.

---

## 📋 Survey Distribution Options

### Option 1: Microsoft Forms

Copy these questions into Microsoft Forms for easy distribution and analysis.

### Option 2: Google Forms

Copy these questions into Google Forms for broader accessibility.

### Option 3: Paper Form

Print this document for in-person workshops.

### Option 4: Post-Session Chat

Use these as discussion prompts for smaller groups.

---

## 📝 Survey Questions

### Section 1: Overall Experience

**Q1. Overall, how would you rate this workshop?** ⭐

| Rating | Description |
| ------ | ----------- |
| 5      | Excellent   |
| 4      | Very Good   |
| 3      | Good        |
| 2      | Fair        |
| 1      | Needs Work  |

**Q2. How likely are you to recommend this workshop to a colleague?** (NPS)

| Score | Label             |
| ----- | ----------------- |
| 10    | Extremely likely  |
| 9     |                   |
| 8     |                   |
| 7     |                   |
| 6     |                   |
| 5     | Neutral           |
| 4     |                   |
| 3     |                   |
| 2     |                   |
| 1     |                   |
| 0     | Not at all likely |

---

### Section 2: Learning Outcomes

**Q3. How well did the workshop meet its stated learning objectives?**

- [ ] Exceeded expectations
- [ ] Met expectations
- [ ] Partially met expectations
- [ ] Did not meet expectations

**Q4. Which learning objectives were most valuable to you?** (Select all that apply)

- [ ] Understanding the agentic workflow (7-step process)
- [ ] Using GitHub Copilot for infrastructure development
- [ ] Writing effective prompts for Copilot
- [ ] Understanding Azure Well-Architected Framework alignment
- [ ] Working with Bicep/Terraform templates
- [ ] Other: **\*\*\*\***\_\_\_\_**\*\*\*\***

**Q5. Before this workshop, how confident were you using AI-assisted tools
for infrastructure development?**

| Rating | Description        |
| ------ | ------------------ |
| 5      | Very confident     |
| 4      | Somewhat confident |
| 3      | Neutral            |
| 2      | Somewhat uncertain |
| 1      | Not confident      |

**Q6. After this workshop, how confident are you using AI-assisted tools
for infrastructure development?**

| Rating | Description        |
| ------ | ------------------ |
| 5      | Very confident     |
| 4      | Somewhat confident |
| 3      | Neutral            |
| 2      | Somewhat uncertain |
| 1      | Not confident      |

---

### Section 3: Content Quality

**Q7. The workshop content was well-organized and easy to follow.**

- [ ] Strongly agree
- [ ] Agree
- [ ] Neutral
- [ ] Disagree
- [ ] Strongly disagree

**Q8. The pace of the workshop was:**

- [ ] Too fast
- [ ] Just right
- [ ] Too slow

**Q9. The difficulty level was:**

- [ ] Too advanced
- [ ] Just right
- [ ] Too basic

**Q10. The hands-on / demo portions were:**

- [ ] Very helpful
- [ ] Somewhat helpful
- [ ] Not helpful
- [ ] N/A - no hands-on portions

---

### Section 4: Instructor Effectiveness

**Q11. The instructor clearly explained concepts and answered questions.**

- [ ] Strongly agree
- [ ] Agree
- [ ] Neutral
- [ ] Disagree
- [ ] Strongly disagree

**Q12. The instructor was engaging and maintained interest.**

- [ ] Strongly agree
- [ ] Agree
- [ ] Neutral
- [ ] Disagree
- [ ] Strongly disagree

---

### Section 5: Practical Application

**Q13. How likely are you to use GitHub Copilot for infrastructure work
in the next 30 days?**

- [ ] Definitely will use
- [ ] Probably will use
- [ ] Might use
- [ ] Probably won't use
- [ ] Definitely won't use

**Q14. What barriers, if any, might prevent you from using these techniques?**
(Select all that apply)

- [ ] Licensing / access to GitHub Copilot
- [ ] Organization policies
- [ ] Lack of time to learn further
- [ ] Technical complexity
- [ ] Unclear business value
- [ ] Need manager approval
- [ ] Other: **\*\*\*\***\_\_\_\_**\*\*\*\***
- [ ] No barriers - ready to start!

**Q15. What specific project or task will you try this on first?**

_Open text field_

---

### Section 6: Improvements

**Q16. What was the most valuable part of this workshop?**

_Open text field_

**Q17. What would you improve about this workshop?**

_Open text field_

**Q18. What topics would you like covered in future workshops?**
(Select all that apply)

- [ ] Advanced Bicep patterns
- [ ] Terraform with Copilot
- [ ] CI/CD pipeline integration
- [ ] Cost optimization with AI
- [ ] Security and compliance automation
- [ ] Multi-environment deployments
- [ ] Troubleshooting and debugging
- [ ] Other: **\*\*\*\***\_\_\_\_**\*\*\*\***

**Q19. Any additional comments or feedback?**

_Open text field_

---

### Section 7: Follow-Up (Optional)

**Q20. Would you like to be contacted about:**

- [ ] Advanced workshops
- [ ] Pilot programs
- [ ] Case study participation
- [ ] Newsletter updates
- [ ] None of the above

**If yes, please provide your email:**

_Email field_

---

## 📊 Survey Analysis Guide

### Key Metrics to Track

| Metric          | Target      | Source |
| --------------- | ----------- | ------ |
| Overall Rating  | ≥4.0/5      | Q1     |
| NPS Score       | ≥50         | Q2     |
| Confidence Lift | ≥1.5 points | Q6-Q5  |
| Intent to Use   | ≥70%        | Q13    |
| Met Objectives  | ≥80%        | Q3     |

### NPS Calculation

```
NPS = % Promoters (9-10) - % Detractors (0-6)
```

- **Promoters**: Scores 9-10
- **Passives**: Scores 7-8
- **Detractors**: Scores 0-6

### Confidence Lift Calculation

```
Confidence Lift = Average(Q6) - Average(Q5)
```

Indicates how much the workshop improved participant confidence.

---

## 📧 Survey Email Template

### Subject Line

`Quick Feedback: Agentic InfraOps Workshop - [Date]`

### Body

```text
Hi [Name],

Thank you for attending today's Agentic InfraOps workshop on [Scenario Name]!

Your feedback helps us improve future sessions. Please take 3-5 minutes to
share your thoughts:

[Survey Link]

As a thank you, here are some resources to continue your learning:
- Repository: https://github.com/jonathan-vella/azure-agentic-infraops
- Documentation: [Link to relevant docs]
- Quick Start Guide: [Link]

Questions? Reply to this email or open an issue on GitHub.

Best regards,
[Your Name]
```

---

## 📈 Feedback Action Matrix

| Feedback Theme          | Score Range | Action                       |
| ----------------------- | ----------- | ---------------------------- |
| Pace too fast           | >30%        | Add more checkpoints         |
| Content too basic       | >20%        | Offer advanced track         |
| Content too advanced    | >20%        | Add prerequisite assessment  |
| Low confidence lift     | <1.0        | More hands-on practice       |
| Low NPS                 | <30         | Comprehensive content review |
| High barrier: licensing | >40%        | Provide trial access info    |

---

**📖 See Also:**

- [Workshop Checklist](workshop-checklist.md) - Delivery preparation
- [Character Reference](character-reference.md) - Scenario personas
- [Demo Delivery Guide](demo-delivery-guide.md) - Presentation tips
