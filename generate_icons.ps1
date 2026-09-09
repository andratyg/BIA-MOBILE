$csharpSource = @"
using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;

public class VerdaticaIconGenerator
{
    public static void DrawVerdaticaEmblem(Graphics g, float centerX, float centerY, float radius)
    {
        // 1. Soft Ambient Halo Glow
        using (Pen glowPen = new Pen(Color.FromArgb(70, 34, 197, 94), radius * 0.16f))
        {
            g.DrawEllipse(glowPen, centerX - radius * 1.04f, centerY - radius * 1.04f, radius * 2.08f, radius * 2.08f);
        }

        // 2. Main Outer Circular Badge with Rich Emerald Gradient (#22C55E to #059669)
        RectangleF circleRect = new RectangleF(centerX - radius, centerY - radius, radius * 2, radius * 2);
        using (LinearGradientBrush circleBrush = new LinearGradientBrush(circleRect, ColorTranslator.FromHtml("#22C55E"), ColorTranslator.FromHtml("#059669"), 135f))
        {
            g.FillEllipse(circleBrush, circleRect);
        }

        // 3. Crisp Frosted Border Rim (White 45% alpha)
        using (Pen rimPen = new Pen(Color.FromArgb(115, 255, 255, 255), radius * 0.05f))
        {
            g.DrawEllipse(rimPen, circleRect);
        }

        // 4. Inner Glassmorphic Disc
        float innerRadius = radius * 0.78f;
        RectangleF innerRect = new RectangleF(centerX - innerRadius, centerY - innerRadius, innerRadius * 2, innerRadius * 2);
        using (LinearGradientBrush innerBrush = new LinearGradientBrush(innerRect, Color.FromArgb(50, 255, 255, 255), Color.FromArgb(18, 255, 255, 255), 45f))
        {
            g.FillEllipse(innerBrush, innerRect);
        }
        using (Pen innerRimPen = new Pen(Color.FromArgb(60, 255, 255, 255), radius * 0.025f))
        {
            g.DrawEllipse(innerRimPen, innerRect);
        }

        // 5. Crisp Modern Eco Leaf Vector (Two organic leaves with central stem)
        float s = radius / 50.0f;

        // --- Main Large Leaf (Graceful curve from bottom-left to top-right) ---
        PointF stemBase = new PointF(centerX - 14.0f * s, centerY + 18.0f * s);
        PointF leafBase = new PointF(centerX - 10.0f * s, centerY + 14.0f * s);
        PointF leafTip  = new PointF(centerX + 18.0f * s, centerY - 18.0f * s);

        using (GraphicsPath mainLeaf = new GraphicsPath())
        {
            mainLeaf.StartFigure();
            // Left curve (bulging upper-left)
            mainLeaf.AddBezier(
                leafBase,
                new PointF(centerX - 24.0f * s, centerY - 2.0f * s),
                new PointF(centerX - 2.0f * s, centerY - 24.0f * s),
                leafTip
            );
            // Right curve (sleek lower-right)
            mainLeaf.AddBezier(
                leafTip,
                new PointF(centerX + 24.0f * s, centerY + 2.0f * s),
                new PointF(centerX + 6.0f * s, centerY + 18.0f * s),
                leafBase
            );
            mainLeaf.CloseFigure();

            using (SolidBrush whiteBrush = new SolidBrush(Color.White))
            {
                g.FillPath(whiteBrush, mainLeaf);
            }
        }

        // --- Stem & Leaf Vein ---
        using (Pen veinPen = new Pen(ColorTranslator.FromHtml("#059669"), 3.2f * s))
        {
            veinPen.StartCap = LineCap.Round;
            veinPen.EndCap = LineCap.Round;
            // Draw main stem to leaf tip
            g.DrawBezier(
                veinPen,
                stemBase,
                new PointF(centerX - 2.0f * s, centerY + 6.0f * s),
                new PointF(centerX + 6.0f * s, centerY - 4.0f * s),
                new PointF(centerX + 15.0f * s, centerY - 15.0f * s)
            );
        }

        // --- Side Sprout (Small budding leaf) ---
        PointF sproutBase = new PointF(centerX - 6.0f * s, centerY + 8.0f * s);
        PointF sproutTip  = new PointF(centerX - 20.0f * s, centerY - 1.0f * s);

        using (GraphicsPath sprout = new GraphicsPath())
        {
            sprout.StartFigure();
            // Top curve of sprout
            sprout.AddBezier(
                sproutBase,
                new PointF(centerX - 10.0f * s, centerY - 1.0f * s),
                new PointF(centerX - 16.0f * s, centerY - 4.0f * s),
                sproutTip
            );
            // Bottom curve of sprout
            sprout.AddBezier(
                sproutTip,
                new PointF(centerX - 18.0f * s, centerY + 8.0f * s),
                new PointF(centerX - 10.0f * s, centerY + 10.0f * s),
                sproutBase
            );
            sprout.CloseFigure();

            using (SolidBrush sproutBrush = new SolidBrush(Color.FromArgb(245, 255, 255, 255)))
            {
                g.FillPath(sproutBrush, sprout);
            }
        }

        // Sprout vein
        using (Pen spVeinPen = new Pen(ColorTranslator.FromHtml("#059669"), 2.2f * s))
        {
            spVeinPen.StartCap = LineCap.Round;
            spVeinPen.EndCap = LineCap.Round;
            g.DrawBezier(
                spVeinPen,
                sproutBase,
                new PointF(centerX - 11.0f * s, centerY + 5.0f * s),
                new PointF(centerX - 15.0f * s, centerY + 3.0f * s),
                new PointF(centerX - 18.0f * s, centerY + 0.5f * s)
            );
        }
    }

    public static void GenerateIcon(int size, string outputPath, string shape)
    {
        using (Bitmap bmp = new Bitmap(size, size))
        {
            using (Graphics g = Graphics.FromImage(bmp))
            {
                g.SmoothingMode = SmoothingMode.HighQuality;
                g.InterpolationMode = InterpolationMode.HighQualityBicubic;
                g.PixelOffsetMode = PixelOffsetMode.HighQuality;

                Rectangle bgRect = new Rectangle(0, 0, size, size);

                if (shape == "Squircle")
                {
                    g.Clear(Color.Transparent);
                    using (LinearGradientBrush bgBrush = new LinearGradientBrush(bgRect, ColorTranslator.FromHtml("#0F3D27"), ColorTranslator.FromHtml("#061A10"), 45f))
                    {
                        float cornerRad = size * 0.225f;
                        using (GraphicsPath path = new GraphicsPath())
                        {
                            float d = cornerRad * 2;
                            path.AddArc(0, 0, d, d, 180, 90);
                            path.AddArc(size - d, 0, d, d, 270, 90);
                            path.AddArc(size - d, size - d, d, d, 0, 90);
                            path.AddArc(0, size - d, d, d, 90, 90);
                            path.CloseFigure();

                            g.FillPath(bgBrush, path);

                            using (Pen borderPen = new Pen(Color.FromArgb(35, 255, 255, 255), size * 0.015f))
                            {
                                g.DrawPath(borderPen, path);
                            }
                        }
                    }

                    float radius = size * 0.35f;
                    DrawVerdaticaEmblem(g, size / 2.0f, size / 2.0f, radius);
                }
                else if (shape == "Circle")
                {
                    g.Clear(Color.Transparent);
                    using (LinearGradientBrush bgBrush = new LinearGradientBrush(bgRect, ColorTranslator.FromHtml("#0F3D27"), ColorTranslator.FromHtml("#061A10"), 45f))
                    {
                        using (GraphicsPath circlePath = new GraphicsPath())
                        {
                            circlePath.AddEllipse(0, 0, size, size);
                            g.FillPath(bgBrush, circlePath);

                            using (Pen borderPen = new Pen(Color.FromArgb(35, 255, 255, 255), size * 0.015f))
                            {
                                g.DrawPath(borderPen, circlePath);
                            }
                        }
                    }

                    float radius = size * 0.36f;
                    DrawVerdaticaEmblem(g, size / 2.0f, size / 2.0f, radius);
                }
                else if (shape == "Foreground")
                {
                    g.Clear(Color.Transparent);
                    float radius = size * 0.28f;
                    DrawVerdaticaEmblem(g, size / 2.0f, size / 2.0f, radius);
                }
                else if (shape == "Transparent")
                {
                    g.Clear(Color.Transparent);
                    float radius = size * 0.44f;
                    DrawVerdaticaEmblem(g, size / 2.0f, size / 2.0f, radius);
                }
            }

            string dir = Path.GetDirectoryName(outputPath);
            if (!Directory.Exists(dir))
            {
                Directory.CreateDirectory(dir);
            }

            bmp.Save(outputPath, ImageFormat.Png);
            Console.WriteLine("Saved: " + outputPath);
        }
    }
}
"@

Add-Type -TypeDefinition $csharpSource -ReferencedAssemblies "System.Drawing"

# 1. Master High-Res Assets
[VerdaticaIconGenerator]::GenerateIcon(1024, "d:\projects\verdatica_flutter\assets\images\app_logo.png", "Squircle")
[VerdaticaIconGenerator]::GenerateIcon(1024, "d:\projects\verdatica_flutter\assets\images\splash_logo.png", "Transparent")

# 2. Android Mipmap Densities
$densities = @(
    @{ Name = "mdpi"; Size = 48 },
    @{ Name = "hdpi"; Size = 72 },
    @{ Name = "xhdpi"; Size = 96 },
    @{ Name = "xxhdpi"; Size = 144 },
    @{ Name = "xxxhdpi"; Size = 192 }
)

foreach ($d in $densities) {
    $folder = "d:\projects\verdatica_flutter\android\app\src\main\res\mipmap-$($d.Name)"
    [VerdaticaIconGenerator]::GenerateIcon($d.Size, "$folder\ic_launcher.png", "Squircle")
    [VerdaticaIconGenerator]::GenerateIcon($d.Size, "$folder\ic_launcher_round.png", "Circle")
}

# 3. Android Adaptive Icon & Splash
$drawableFolder = "d:\projects\verdatica_flutter\android\app\src\main\res\drawable"
[VerdaticaIconGenerator]::GenerateIcon(432, "$drawableFolder\ic_launcher_foreground.png", "Foreground")
[VerdaticaIconGenerator]::GenerateIcon(512, "$drawableFolder\ic_splash_logo.png", "Transparent")

Write-Output "Generation completed!"
