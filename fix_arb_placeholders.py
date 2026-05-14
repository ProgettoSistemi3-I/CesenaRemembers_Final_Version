import os
import json

BASE = r'c:\Users\lenovo\Desktop\CesenaRemembers_Final_Version\lib'

en_arb_path = os.path.join(BASE, r'l10n\app_en.arb')
it_arb_path = os.path.join(BASE, r'l10n\app_it.arb')

with open(en_arb_path, 'r', encoding='utf-8') as f:
    en_arb = json.load(f)

en_arb["@setupUsernameInvalid"] = {
    "placeholders": {
        "min": {"type": "int"},
        "max": {"type": "int"}
    }
}

with open(en_arb_path, 'w', encoding='utf-8') as f:
    json.dump(en_arb, f, ensure_ascii=False, indent=2)

print("Fixed ARB placeholders.")
