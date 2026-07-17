#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter


ROOT = Path(__file__).resolve().parents[2]
OUTPUT_DIR = ROOT / "CatLogicMansion" / "GameData" / "Art"
APP_ICON_PATH = ROOT / "CatLogicMansion" / "Assets.xcassets" / "AppIcon.appiconset" / "app-icon-1024.png"
LAUNCH_MARK_PATH = ROOT / "CatLogicMansion" / "Assets.xcassets" / "LaunchMark.imageset" / "launch-mark@3x.png"
SIZE = 96


PALETTE = {
    "cream": "#FFF3D8",
    "cream_shadow": "#E9CFA7",
    "walnut": "#5A2E1A",
    "walnut_dark": "#35190E",
    "cat": "#F58A2F",
    "cat_light": "#FFB15C",
    "blush": "#FFACA0",
    "gold": "#FFC84E",
    "gold_dark": "#BA7C1F",
    "floor_light": "#F3B96F",
    "floor_dark": "#DA9151",
    "wall": "#7A3D24",
    "wall_light": "#B06A3A",
    "green": "#58B86C",
    "green_dark": "#2E7F49",
    "red": "#E65548",
    "blue": "#6D95D8",
    "blue_dark": "#3E5B98",
    "stone": "#8B91A1",
    "stone_dark": "#585E6E",
    "transparent": (0, 0, 0, 0),
}


def canvas() -> Image.Image:
    return Image.new("RGBA", (SIZE, SIZE), PALETTE["transparent"])


def save(name: str, image: Image.Image) -> None:
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    image.save(OUTPUT_DIR / f"{name}.png")


def rounded(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], radius: int, fill: str, outline: str | None = None, width: int = 1) -> None:
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def art_floor(name: str, light: bool) -> None:
    image = canvas()
    draw = ImageDraw.Draw(image)
    base = PALETTE["floor_light"] if light else PALETTE["floor_dark"]
    inset = PALETTE["cream"] if light else "#E6A260"
    rounded(draw, (4, 4, 92, 92), 14, base, "#BA6B37", 3)
    draw.line((16, 26, 80, 26), fill=inset, width=3)
    draw.line((16, 52, 80, 52), fill=inset, width=2)
    draw.line((16, 76, 80, 76), fill="#C77543", width=2)
    save(name, image)


def art_wall() -> None:
    image = canvas()
    draw = ImageDraw.Draw(image)
    rounded(draw, (4, 4, 92, 92), 12, PALETTE["wall"], PALETTE["walnut_dark"], 4)
    for y in (18, 42, 66):
        draw.line((8, y, 88, y), fill=PALETTE["wall_light"], width=4)
    for x, y0, y1 in ((30, 8, 42), (61, 42, 88), (48, 8, 42), (20, 42, 88), (76, 8, 42)):
        draw.line((x, y0, x, y1), fill="#5E2D1B", width=3)
    draw.rounded_rectangle((12, 10, 84, 18), radius=4, fill="#A45D35")
    save("art_wall", image)


def art_cat() -> None:
    art_cat_from_original_game_page()


def art_cat_from_original_game_page() -> None:
    scale = 4
    sprite = Image.new("RGBA", (SIZE * scale, SIZE * scale), PALETTE["transparent"])
    draw = ImageDraw.Draw(sprite)

    def box(values: tuple[int, int, int, int]) -> tuple[int, int, int, int]:
        return tuple(value * scale for value in values)

    def points(values: list[tuple[int, int]]) -> list[tuple[int, int]]:
        return [(x * scale, y * scale) for x, y in values]

    # This matches the original GameScene-drawn cat token used before the first
    # PNG art pass: compact head, cream outline, triangular ears, soft shadow.
    draw.ellipse(box((8, 68, 88, 92)), fill=(80, 38, 20, 52))

    draw.polygon(points([(18, 38), (34, 4), (50, 38)]), fill=PALETTE["cream"])
    draw.polygon(points([(78, 38), (62, 4), (46, 38)]), fill=PALETTE["cream"])
    draw.polygon(points([(24, 36), (34, 13), (44, 36)]), fill=PALETTE["cat"])
    draw.polygon(points([(72, 36), (62, 13), (52, 36)]), fill=PALETTE["cat"])

    draw.ellipse(box((10, 20, 86, 92)), fill=PALETTE["cream"])
    draw.ellipse(box((17, 27, 79, 85)), fill=PALETTE["cat"])
    draw.ellipse(box((30, 43, 40, 53)), fill=PALETTE["walnut_dark"])
    draw.ellipse(box((56, 43, 66, 53)), fill=PALETTE["walnut_dark"])
    draw.ellipse(box((43, 55, 53, 65)), fill=PALETTE["walnut"])
    draw.ellipse(box((25, 59, 39, 73)), fill=PALETTE["blush"])
    draw.ellipse(box((57, 59, 71, 73)), fill=PALETTE["blush"])

    save("art_cat_miso", sprite.resize((SIZE, SIZE), Image.Resampling.LANCZOS))


def art_cat_from_launch_mark() -> None:
    mark = Image.open(LAUNCH_MARK_PATH).convert("RGBA")

    cream = mark.getpixel((180, 360))
    orange = mark.getpixel((360, 418))
    walnut = mark.getpixel((299, 405))
    blush = mark.getpixel((282, 463))

    scale = 4
    sprite = Image.new("RGBA", (SIZE * scale, SIZE * scale), PALETTE["transparent"])
    draw = ImageDraw.Draw(sprite)

    def box(values: tuple[int, int, int, int]) -> tuple[int, int, int, int]:
        return tuple(value * scale for value in values)

    def points(values: list[tuple[int, int]]) -> list[tuple[int, int]]:
        return [(x * scale, y * scale) for x, y in values]

    # Keep the same cat identity as LaunchMark, but draw it as a clean board
    # token: transparent background, complete ears, complete round face.
    draw.polygon(points([(17, 35), (34, 4), (51, 39)]), fill=cream)
    draw.polygon(points([(79, 35), (62, 4), (45, 39)]), fill=cream)
    draw.polygon(points([(31, 31), (36, 17), (43, 35)]), fill=orange)
    draw.polygon(points([(65, 31), (60, 17), (53, 35)]), fill=orange)

    draw.ellipse(box((14, 25, 82, 93)), fill=orange)
    draw.ellipse(box((29, 48, 39, 58)), fill=walnut)
    draw.ellipse(box((57, 48, 67, 58)), fill=walnut)
    draw.ellipse(box((44, 59, 52, 67)), fill=walnut)
    draw.ellipse(box((26, 62, 40, 76)), fill=blush)
    draw.ellipse(box((56, 62, 70, 76)), fill=blush)

    save("art_cat_miso", sprite.resize((SIZE, SIZE), Image.Resampling.LANCZOS))


def art_cat_from_app_icon() -> None:
    icon = Image.open(APP_ICON_PATH).convert("RGBA")
    crop_box = (285, 300, 739, 805)
    crop = icon.crop(crop_box)

    mask = Image.new("L", crop.size, 0)
    draw = ImageDraw.Draw(mask)

    # Shape mask follows the existing App Icon head: one large round face plus
    # the two cream-trimmed ears. This preserves the icon's exact colors.
    draw.ellipse((34, 78, 420, 492), fill=255)
    draw.polygon([(62, 120), (140, 8), (186, 150)], fill=255)
    draw.polygon([(392, 120), (314, 8), (268, 150)], fill=255)
    mask = mask.filter(ImageFilter.GaussianBlur(radius=1.2))

    extracted = Image.new("RGBA", crop.size, PALETTE["transparent"])
    extracted.alpha_composite(crop)
    extracted.putalpha(mask)

    bbox = extracted.getbbox()
    if bbox:
        extracted = extracted.crop(bbox)

    sprite = Image.new("RGBA", (SIZE, SIZE), PALETTE["transparent"])
    extracted.thumbnail((88, 88), Image.Resampling.LANCZOS)
    sprite.alpha_composite(
        extracted,
        ((SIZE - extracted.width) // 2, (SIZE - extracted.height) // 2)
    )
    save("art_cat_miso", sprite)


def art_treat() -> None:
    image = canvas()
    draw = ImageDraw.Draw(image)
    draw.ellipse((14, 26, 82, 76), fill=PALETTE["cream"], outline=PALETTE["gold_dark"], width=4)
    draw.ellipse((26, 34, 62, 68), fill=PALETTE["cat"], outline=PALETTE["cream"], width=3)
    draw.polygon([(60, 51), (78, 37), (78, 65)], fill=PALETTE["cat"])
    draw.polygon([(32, 51), (20, 41), (20, 61)], fill=PALETTE["cat_light"])
    draw.ellipse((36, 45, 42, 51), fill=PALETTE["walnut_dark"])
    draw.line((47, 41, 56, 51), fill=PALETTE["cream"], width=3)
    draw.line((56, 51, 47, 61), fill=PALETTE["cream"], width=3)
    save("art_treat", image)


def art_key() -> None:
    image = canvas()
    draw = ImageDraw.Draw(image)
    draw.ellipse((12, 27, 44, 59), outline=PALETTE["gold"], width=9)
    draw.ellipse((23, 38, 33, 48), fill=PALETTE["gold"])
    rounded(draw, (40, 39, 82, 51), 6, PALETTE["gold"], PALETTE["gold_dark"], 2)
    rounded(draw, (70, 50, 82, 70), 3, PALETTE["gold"], PALETTE["gold_dark"], 2)
    rounded(draw, (57, 50, 69, 63), 3, PALETTE["gold"], PALETTE["gold_dark"], 2)
    save("art_key", image)


def art_box() -> None:
    image = canvas()
    draw = ImageDraw.Draw(image)
    rounded(draw, (12, 12, 84, 84), 14, "#A7673A", PALETTE["cream"], 4)
    rounded(draw, (42, 14, 54, 82), 4, "#663018")
    rounded(draw, (14, 42, 82, 54), 4, "#663018")
    draw.line((20, 22, 76, 76), fill="#C8864E", width=4)
    draw.line((76, 22, 20, 76), fill="#C8864E", width=4)
    save("art_box", image)


def art_button(name: str, pressed: bool) -> None:
    image = canvas()
    draw = ImageDraw.Draw(image)
    shadow_alpha = 36 if pressed else 42
    draw.ellipse((16, 18, 80, 82), fill=(80, 38, 20, shadow_alpha))

    if pressed:
        draw.ellipse((13, 13, 83, 83), fill=(78, 179, 102, 74))
        draw.ellipse((18, 18, 78, 78), fill=PALETTE["cream"], outline=PALETTE["walnut"], width=3)
        draw.ellipse((28, 31, 68, 71), fill=PALETTE["green"], outline=PALETTE["cream_shadow"], width=3)
        draw.arc((25, 28, 71, 74), start=205, end=335, fill=PALETTE["cream"], width=4)
        draw.arc((31, 34, 65, 68), start=205, end=335, fill="#BFE7C8", width=3)
        save(name, image)
        return

    draw.ellipse((16, 14, 80, 78), fill=PALETTE["cream"], outline=PALETTE["walnut"], width=4)
    draw.ellipse((24, 22, 72, 70), fill=PALETTE["red"], outline=PALETTE["cream_shadow"], width=3)
    save(name, image)


def art_exit(name: str, open_state: bool) -> None:
    image = canvas()
    draw = ImageDraw.Draw(image)
    outer = PALETTE["green_dark"] if open_state else PALETTE["stone_dark"]
    inner = "#6AD97F" if open_state else PALETTE["stone"]
    glow = "#D8FFD8" if open_state else "#CED2DA"

    draw.rounded_rectangle((22, 24, 74, 88), radius=10, fill=PALETTE["cream"])
    draw.pieslice((22, 4, 74, 56), 180, 360, fill=PALETTE["cream"])
    draw.rounded_rectangle((28, 30, 68, 84), radius=7, fill=outer)
    draw.pieslice((28, 12, 68, 52), 180, 360, fill=outer)
    draw.rounded_rectangle((34, 34, 62, 82), radius=5, fill=inner)
    draw.pieslice((34, 20, 62, 48), 180, 360, fill=inner)

    if open_state:
        draw.rectangle((42, 36, 54, 82), fill=glow)
        draw.pieslice((42, 24, 54, 48), 180, 360, fill=glow)
    else:
        draw.line((38, 48, 58, 48), fill=PALETTE["cream_shadow"], width=4)
        draw.line((38, 62, 58, 62), fill=PALETTE["cream_shadow"], width=4)
        draw.ellipse((55, 55, 63, 63), fill=PALETTE["gold"])
    save(name, image)


def art_door(name: str, open_state: bool) -> None:
    image = canvas()
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle((18, 12, 78, 88), radius=14, fill=PALETTE["cream"])
    draw.rounded_rectangle((24, 18, 72, 84), radius=10, fill=PALETTE["walnut"])

    if open_state:
        draw.rounded_rectangle((30, 24, 44, 82), radius=5, fill="#8F552E")
        draw.rounded_rectangle((52, 24, 66, 82), radius=5, fill="#8F552E")
        draw.polygon([(44, 28), (52, 24), (52, 82), (44, 78)], fill="#4A2818")
        draw.line((34, 42, 42, 42), fill=PALETTE["gold"], width=3)
        draw.line((54, 42, 62, 42), fill=PALETTE["gold"], width=3)
    else:
        draw.rounded_rectangle((30, 24, 66, 82), radius=7, fill="#6B3A20")
        draw.line((34, 42, 62, 42), fill=PALETTE["gold"], width=5)
        draw.line((34, 60, 62, 60), fill=PALETTE["gold_dark"], width=4)
        draw.line((48, 26, 48, 80), fill="#4A2818", width=3)
        draw.ellipse((56, 51, 64, 59), fill=PALETTE["gold"])
    save(name, image)


def art_bridge(name: str, enabled: bool) -> None:
    image = canvas()
    draw = ImageDraw.Draw(image)
    base = PALETTE["blue"] if enabled else "#7D8493"
    edge = PALETTE["blue_dark"] if enabled else PALETTE["stone_dark"]
    rounded(draw, (8, 24, 88, 72), 14, base, PALETTE["cream"], 4)
    for x in (24, 40, 56, 72):
        draw.line((x, 30, x, 66), fill=edge, width=4)
    if enabled:
        draw.line((16, 38, 80, 38), fill=PALETTE["cream"], width=3)
        draw.line((16, 58, 80, 58), fill=PALETTE["cream"], width=3)
    else:
        draw.line((22, 34, 74, 62), fill=PALETTE["cream_shadow"], width=5)
        draw.line((74, 34, 22, 62), fill=PALETTE["cream_shadow"], width=5)
    save(name, image)


def art_unknown() -> None:
    image = canvas()
    draw = ImageDraw.Draw(image)
    draw.ellipse((24, 24, 72, 72), fill=PALETTE["blue"], outline=PALETTE["cream"], width=4)
    draw.text((44, 35), "?", fill=PALETTE["cream"], anchor="mm")
    save("art_unknown", image)


def main() -> None:
    art_floor("art_floor_light", True)
    art_floor("art_floor_dark", False)
    art_wall()
    art_cat()
    art_treat()
    art_key()
    art_box()
    art_button("art_button_up", False)
    art_button("art_button_down", True)
    art_exit("art_exit_open", True)
    art_exit("art_exit_locked", False)
    art_door("art_door_open", True)
    art_door("art_door_locked", False)
    art_bridge("art_bridge_enabled", True)
    art_bridge("art_bridge_disabled", False)
    art_unknown()


if __name__ == "__main__":
    main()
