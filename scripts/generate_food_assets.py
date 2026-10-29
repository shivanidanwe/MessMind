import os
from PIL import Image, ImageDraw, ImageFont

os.makedirs('mobile_app/assets/images', exist_ok=True)

def create_food_image(filename, title, subtitle, main_color, accent_color):
    width, height = 800, 500
    img = Image.new('RGB', (width, height), color=main_color)
    draw = ImageDraw.Draw(img)

    # Decorative background shapes
    draw.ellipse([(-100, -100), (300, 300)], fill=accent_color)
    draw.ellipse([(500, 200), (900, 600)], fill=accent_color)

    # Plate circle
    plate_center = (400, 220)
    draw.ellipse([(plate_center[0]-140, plate_center[1]-140), (plate_center[0]+140, plate_center[1]+140)], fill=(255, 255, 255), outline=(220, 220, 220), width=6)
    draw.ellipse([(plate_center[0]-120, plate_center[1]-120), (plate_center[0]+120, plate_center[1]+120)], fill=(245, 245, 240))

    # Inner food bowls / items
    draw.ellipse([(plate_center[0]-80, plate_center[1]-70), (plate_center[0]-20, plate_center[1]-10)], fill=(217, 119, 6)) # Curry/Dal
    draw.ellipse([(plate_center[0]+10, plate_center[1]-70), (plate_center[0]+70, plate_center[1]-10)], fill=(22, 101, 52)) # Sabzi
    draw.ellipse([(plate_center[0]-50, plate_center[1]+10), (plate_center[0]+40, plate_center[1]+80)], fill=(250, 250, 250), outline=(210, 210, 210), width=2) # Rice

    # Banner overlay at bottom
    draw.rectangle([(0, 380), (800, 500)], fill=(23, 35, 29))

    # Try font loading or default fallback
    try:
        font_large = ImageFont.truetype("arial.ttf", 32)
        font_small = ImageFont.truetype("arial.ttf", 20)
    except Exception:
        font_large = ImageFont.load_default()
        font_small = ImageFont.load_default()

    draw.text((30, 400), title, fill=(255, 255, 255), font=font_large)
    draw.text((30, 445), subtitle, fill=(245, 158, 11), font=font_small)

    filepath = os.path.join('mobile_app/assets/images', filename)
    img.save(filepath, format='PNG')
    print(f"Generated asset: {filepath}")

create_food_image('thali.png', 'Special North Indian Thali', 'Paneer Butter Masala, Dal Tadka, Jeera Rice & Roti', (22, 101, 52), (15, 118, 110))
create_food_image('rice_curry.png', 'South Indian Meals', 'Steamed Rice, Sambar, Rasam & Curd', (15, 118, 110), (245, 158, 11))
create_food_image('idli_sambar.png', 'Fresh Breakfast Combo', 'Hot Idli, Vada, Coconut Chutney & Filter Coffee', (245, 158, 11), (22, 101, 52))
create_food_image('canteen_mess.png', 'Campus Central Mess', 'Smarter Meals. Less Waste. Better Planning.', (30, 41, 59), (15, 118, 110))
