"""
Template Renderer

Loads document-type-specific templates and renders them with extracted data.
"""

import os
from pathlib import Path
from typing import Dict, Any

from jinja2 import Template, Environment, FileSystemLoader

TEMPLATE_DIR = Path(__file__).parent.parent / "templates"

# Simple fallback if jinja not available
try:
    env = Environment(loader=FileSystemLoader(str(TEMPLATE_DIR)), autoescape=False)
except Exception:
    env = None


def render_agent_prompt(doc_type: str, data: Dict[str, Any], text: str) -> str:
    """
    Render the agent instruction prompt for a given document type.

    Args:
        doc_type: Document type (invoice, business_card, etc.)
        data: Extracted structured data (amount, vendor, ...)
        text: Full OCR text

    Returns:
        Rendered prompt string
    """
    template_map = {
        "invoice": "invoice.md",
        "business_card": "business_card.md",
        "receipt": "receipt.md",
        "table": "table.md",
        "contract": "contract.md",
        "general": "general.md",
    }

    template_name = template_map.get(doc_type, "general.md")
    template_path = TEMPLATE_DIR / template_name

    if not template_path.exists():
        return f"Document type: {doc_type}\nNo specific template available."

    try:
        with open(template_path, "r", encoding="utf-8") as f:
            content = f.read()

        # Use simple Jinja template passing
        if env:
            template = env.get_template(template_name)
            return template.render(**data, text=text)
        else:
            # Fallback: basic string replacement for {{ var }}
            rendered = content
            for key, value in data.items():
                placeholder = f"{{{{{key}}}}}"
                rendered = rendered.replace(placeholder, str(value) if value else "unknown")
            return rendered
    except Exception as e:
        return f"Template rendering failed: {e}"


if __name__ == "__main__":
    # Quick test
    test_data = {"amount": "1200", "vendor": "某某公司", "date": "2025-03-15"}
    prompt = render_agent_prompt("invoice", test_data, "")
    print(prompt)
