import firebase_admin
from firebase_admin import credentials, firestore
import re
import datetime

# 1. Initialize Firebase
cred = credentials.Certificate('d:/HealMeal/archive/tools/healmeal-69371-firebase-adminsdk-fbsvc-3b76108cc1.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

# 2. Parse data.js
with open('d:/HealMeal/assets/data.js', 'r', encoding='utf-8') as f:
    content = f.read()

match = re.search(r'\[(.*)\];', content, re.DOTALL)
if not match:
    print("Array not found in data.js")
    exit(1)

products_raw = match.group(1)
object_blocks = re.split(r'\},', products_raw)

def extract_field(block, field):
    pattern = rf'{field}\s*:\s*(?P<quote>["\'])(?P<value>.*?)(?P=quote)'
    match = re.search(pattern, block, re.DOTALL)
    if match:
        return match.group('value').strip()
    pattern_num = rf'{field}\s*:\s*(?P<value>\d+\.?\d*)'
    match = re.search(pattern_num, block)
    if match:
        return match.group('value').strip()
    return ""

def map_category(js_cat, name, desc):
    js_cat = js_cat.lower()
    name = name.lower()
    desc = desc.lower()
    if 'diabetes' in js_cat or 'diabetes' in name or 'glucometer' in name:
        return 'diabeticCare'
    if 'blood pressure' in js_cat or 'statin' in name or 'cholesterol' in name or 'heart' in desc:
        return 'cardiacCare'
    if 'baby care' in js_cat or 'women care' in js_cat or 'pregnancy' in desc or 'diaper' in name:
        return 'babyMomCare'
    if any(k in js_cat for k in ['dermatology', 'dental', 'personal care', 'health devices']):
        return 'healthcare'
    if 'supplement' in js_cat or 'ayurveda' in js_cat or 'vitamin' in desc or 'protein' in name:
        return 'supplement'
    return 'medicine'

# 3. Seed Categories
categories = {
    'medicine': 'Medicines',
    'healthcare': 'Healthcare',
    'supplement': 'Supplements',
    'babyMomCare': 'Baby & Mom Care',
    'petCare': 'Pet Care',
    'diabeticCare': 'Diabetic Care',
    'cardiacCare': 'Cardiac Care',
}

print("Seeding categories...")
for slug, name in categories.items():
    db.collection('categories').document(slug).set({
        'name': name,
        'slug': slug,
        'createdAt': firestore.SERVER_TIMESTAMP
    })

# 4. Seed Products
print("Seeding products...")
processed_count = 0
batch = db.batch()

for i, block in enumerate(object_blocks):
    name = extract_field(block, "drugName")
    if not name:
        continue
    
    brand = extract_field(block, "manufacturer")
    image = extract_field(block, "image")
    desc = extract_field(block, "description")
    price = extract_field(block, "price")
    js_cat = extract_field(block, "category")
    slug = map_category(js_cat, name, desc)
            
    try:
        price_float = float(price) if price and price != "N/A" else 0.0
    except:
        price_float = 0.0
        
    mrp = price_float * 1.15
    
    if image.startswith("//"):
        image = "https:" + image

    product_id = f'p_hm_{processed_count:03d}'
    product_data = {
        'id': product_id,
        'name': name,
        'brandName': brand,
        'genericName': js_cat,
        'imageUrl': image,
        'description': desc,
        'mrp': round(mrp, 2),
        'salePrice': round(price_float, 2),
        'categorySlug': slug,
        'strength': 'N/A',
        'dosageForm': 'N/A',
        'inStock': True,
        'isRxRequired': slug in ['medicine', 'cardiacCare'],
        'rating': 4.5,
        'reviewCount': 150,
        'discountPercent': 15,
        'cashback': 10,
        'stockLeft': 100,
        'createdAt': firestore.SERVER_TIMESTAMP
    }
    
    doc_ref = db.collection('products').document(product_id)
    batch.set(doc_ref, product_data)
    processed_count += 1
    
    # Commit in batches of 400
    if processed_count % 400 == 0:
        batch.commit()
        batch = db.batch()
        print(f"Committed {processed_count} products...")

batch.commit()
print(f"Successfully restored {processed_count} products to Firestore.")
