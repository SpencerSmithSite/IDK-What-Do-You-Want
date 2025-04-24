"""Script to generate app store graphics for the IDK What Do You Want app."""
# pylint: disable=import-error

import os
from PIL import Image, ImageDraw, ImageFont

def create_app_icon():
    """Generate the app icon (512x512 pixels) with a red background and white text."""
    # Create a new image with a transparent background
    size = 1024
    image = Image.new('RGBA', (size, size), (255, 255, 255, 0))
    draw = ImageDraw.Draw(image)
    
    # Draw the background circle
    circle_color = (255, 107, 107)  # #FF6B6B
    circle_margin = size // 8
    draw.ellipse([circle_margin, circle_margin, size - circle_margin, size - circle_margin], 
                 fill=circle_color)
    
    # Draw the fork and knife
    center = size // 2
    # Fork
    fork_width = size // 4
    fork_height = size // 2
    fork_x = center - fork_width // 2
    fork_y = center - fork_height // 2
    draw.rectangle([fork_x, fork_y, fork_x + fork_width, fork_y + fork_height], 
                  fill='white')
    
    # Knife
    knife_width = size // 4
    knife_height = size // 2
    knife_x = center - knife_width // 2
    knife_y = center - knife_height // 2
    draw.rectangle([knife_x, knife_y, knife_x + knife_width, knife_y + knife_height], 
                  fill='white')
    
    # Add "IDK" text
    try:
        font = ImageFont.truetype("Arial", size // 4)
    except OSError:
        font = ImageFont.load_default()
    text = "IDK"
    text_bbox = draw.textbbox((0, 0), text, font=font)
    text_width = text_bbox[2] - text_bbox[0]
    text_height = text_bbox[3] - text_bbox[1]
    text_x = (size - text_width) // 2
    text_y = (size - text_height) // 2
    draw.text((text_x, text_y), text, fill='white', font=font)
    
    # Save the image
    os.makedirs('assets/store_graphics', exist_ok=True)
    image.save('assets/store_graphics/app_icon.png')

def create_feature_graphic():
    """Generate the feature graphic (1024x500 pixels) with gradient background and app title."""
    # Create a new image
    width = 1024
    height = 500
    image = Image.new('RGB', (width, height), (255, 255, 255))
    draw = ImageDraw.Draw(image)
    
    # Draw gradient background
    for y in range(height):
        r = int(255 - (y / height) * 50)  # #FF6B6B to #FF8E8E
        g = int(107 - (y / height) * 20)
        b = int(107 - (y / height) * 20)
        draw.line([(0, y), (width, y)], fill=(r, g, b))
    
    # Add text
    try:
        title_font = ImageFont.truetype("Arial", 60)
        subtitle_font = ImageFont.truetype("Arial", 30)
    except OSError:
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
    
    title = "IDK What Do You Want?"
    subtitle = "Let us help you decide where to eat"
    
    # Draw title
    title_bbox = draw.textbbox((0, 0), title, font=title_font)
    title_width = title_bbox[2] - title_bbox[0]
    title_x = (width - title_width) // 2
    title_y = height // 3
    draw.text((title_x, title_y), title, fill='white', font=title_font)
    
    # Draw subtitle
    subtitle_bbox = draw.textbbox((0, 0), subtitle, font=subtitle_font)
    subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
    subtitle_x = (width - subtitle_width) // 2
    subtitle_y = title_y + 80
    draw.text((subtitle_x, subtitle_y), subtitle, fill='white', font=subtitle_font)
    
    # Save the image
    image.save('assets/store_graphics/feature_graphic.png')

if __name__ == '__main__':
    create_app_icon()
    create_feature_graphic() 