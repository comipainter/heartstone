shader_type canvas_item;

// 椭圆中心（UV 坐标）
uniform vec2 ellipse_center = vec2(0.5, 0.5);

// 拆分为两个带范围的 float，以便在检查器中显示滑块
uniform float ellipse_scale_x : hint_range(0.1, 2.0) = 1.0;
uniform float ellipse_scale_y : hint_range(0.1, 2.0) = 1.0;

uniform float global_scale : hint_range(0.1, 2.0) = 1.0;

void fragment() {
    vec2 uv = UV;
    vec2 centered_uv = (uv - ellipse_center) * global_scale;
    
    // 使用拆分后的 scale
    vec2 normalized_uv = vec2(
        centered_uv.x / ellipse_scale_x,
        centered_uv.y / ellipse_scale_y
    );
    
    if (dot(normalized_uv, normalized_uv) > 1.0) {
        discard;
    }
    
    COLOR = texture(TEXTURE, uv);
}