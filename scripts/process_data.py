import re

# Read data.js
with open('d:/HealMeal/assets/data.js', 'r', encoding='utf-8') as f:
    content = f.read()

# Extract everything between [ and ];
match = re.search(r'\[(.*)\];', content, re.DOTALL)
if not match:
    print("Array not found")
    exit(1)

products_raw = match.group(1)

# Split by the end of an object
object_blocks = re.split(r'\},', products_raw)

def extract_field(block, field):
    # Match "field: 'value'" or 'field: "value"'
    pattern = rf'{field}\s*:\s*(?P<quote>["\'])(?P<value>.*?)(?P=quote)'
    match = re.search(pattern, block, re.DOTALL)
    if match:
        return match.group('value').strip()
    # Match numbers
    pattern_num = rf'{field}\s*:\s*(?P<value>\d+\.?\d*)'
    match = re.search(pattern_num, block)
    if match:
        return match.group('value').strip()
    return ""

# Comprehensive Category Mapping
def map_category(js_cat, name, desc):
    js_cat = js_cat.lower()
    name = name.lower()
    desc = desc.lower()
    
    # Priority 1: Diabetic Care
    if 'diabetes' in js_cat or 'diabetes' in name or 'glucometer' in name:
        return 'diabeticCare'
    
    # Priority 2: Cardiac Care
    if 'blood pressure' in js_cat or 'statin' in name or 'cholesterol' in name or 'heart' in desc:
        return 'cardiacCare'
    
    # Priority 3: Baby & Mom Care
    if 'baby care' in js_cat or 'women care' in js_cat or 'pregnancy' in desc or 'diaper' in name:
        return 'babyMomCare'
    
    # Priority 4: Healthcare (Dermatology, Dental, Personal Care, Devices)
    if any(k in js_cat for k in ['dermatology', 'dental', 'personal care', 'health devices']):
        return 'healthcare'
    
    # Priority 5: Supplements
    if 'supplement' in js_cat or 'ayurveda' in js_cat or 'vitamin' in desc or 'protein' in name:
        return 'supplement'
    
    # Default: Medicine
    return 'medicine'

dart_products = []
processed_count = 0

for block in object_blocks:
    name = extract_field(block, "drugName")
    if not name:
        continue
    
    brand = extract_field(block, "manufacturer")
    image = extract_field(block, "image")
    desc = extract_field(block, "description")
    price = extract_field(block, "price")
    js_cat = extract_field(block, "category")
    
    # Map category
    slug = map_category(js_cat, name, desc)
            
    if not price or price == "N/A": price = "0"
    try:
        price_float = float(price)
    except:
        price_float = 0.0
        
    mrp = price_float * 1.15
    
    # Clean and escape
    name = name.replace("'", "\\'").replace("\n", " ")
    brand = brand.replace("'", "\\'").replace("\n", " ")
    desc = desc.replace("'", "\\'").replace("\n", " ")
    js_cat = js_cat.replace("'", "\\'").replace("\n", " ")
    
    # Fix image URLs (some might be missing protocol)
    if image.startswith("//"):
        image = "https:" + image
    
    dart_products.append(f"""  Product(
    id: 'p_hm_{processed_count:03d}',
    name: '{name}',
    slug: '{name.lower().replace(" ", "-")}',
    brandName: '{brand}',
    genericName: '{js_cat}',
    imageUrl: '{image}',
    description: '{desc}',
    mrp: {mrp:.2f},
    salePrice: {price_float:.2f},
    categorySlug: '{slug}',
    strength: 'N/A',
    dosageForm: 'N/A',
    inStock: true,
    isRxRequired: { "true" if slug in ['medicine', 'cardiacCare'] else "false" },
    rating: 4.5,
    reviewCount: 150,
    discountPercent: 15,
    cashback: 10,
    stockLeft: 100,
  ),""")
    processed_count += 1

output = """import '../data/models.dart';

final List<Product> sampleProducts = [
""" + "\n".join(dart_products) + "\n];"

with open('d:/HealMeal/lib/core/data/sample_products.dart', 'w', encoding='utf-8') as f:
    f.write(output)

print(f"Successfully processed {processed_count} products.")
