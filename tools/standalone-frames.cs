// Copyright (C) 2026 Vasily Nishchiret
// SPDX-License-Identifier: GPL-3.0-or-later
// Private reference exporter. Never add its output to a game package.
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Linq;
using System.Text;

public static class StandaloneFrames
{
    sealed class Lump { public string Name; public int Position; public int Length; }
    static short S16(byte[] b, int p) { return BitConverter.ToInt16(b, p); }
    static int I32(byte[] b, int p) { return BitConverter.ToInt32(b, p); }
    static void Check(byte[] b, int p, int size) { if (p < 0 || size < 0 || (long)p + size > b.Length) throw new InvalidDataException("Invalid WAD patch bounds"); }

    public static string Export(string wadPath, string privateRoot, string assetRoot, bool force)
    {
        byte[] wad = File.ReadAllBytes(wadPath);
        Check(wad, 0, 12);
        if (Encoding.ASCII.GetString(wad, 0, 4) != "IWAD") throw new InvalidDataException("Expected a legal Hexen IWAD");
        int count = I32(wad, 4), directory = I32(wad, 8);
        Check(wad, directory, checked(count * 16));
        var lumps = new List<Lump>();
        for (int i = 0; i < count; ++i) {
            int at = directory + i * 16;
            var l = new Lump { Position = I32(wad, at), Length = I32(wad, at + 4), Name = Encoding.ASCII.GetString(wad, at + 8, 8).TrimEnd('\0') };
            Check(wad, l.Position, l.Length);
            lumps.Add(l);
        }
        var paletteLump = lumps.First(x => x.Name == "PLAYPAL");
        Check(wad, paletteLump.Position, 768);
        var rows = new List<string> { "set,lump,logical_name,reference_file,standalone_file,width,height,left_offset,top_offset,runtime_name,opaque_min_x,opaque_min_y,opaque_max_x,opaque_max_y" };
        foreach (var l in lumps.Where(x => x.Name.StartsWith("FAXE") || x.Name.StartsWith("ETTN") || x.Name.StartsWith("ETTB"))) {
            if (l.Name.Length < 6 || l.Length < 8) continue;
            string set = l.Name.StartsWith("FAXE") ? "weapons/axe" : "monsters/ettin";
            string group = l.Name.StartsWith("FAXE") ? "axe" : l.Name.StartsWith("ETTN") ? "ettin" : "ettin_gib";
            string runtime = l.Name.StartsWith("FAXE") ? "ARXA" : l.Name.StartsWith("ETTN") ? "ARET" : "AREB";
            string suffix = l.Name.Substring(4).ToLowerInvariant();
            string stem = "arpg_" + (group == "axe" ? "wp_" : "mn_") + group + "_" + suffix;
            string relative = (group == "axe" ? "sprites/weapons/axe/" : "sprites/monsters/ettin/") + stem + ".png";
            string reference = set + "/" + stem + "_ref.png";
            int w = S16(wad, l.Position), h = S16(wad, l.Position + 2);
            int left = S16(wad, l.Position + 4), top = S16(wad, l.Position + 6);
            if (w <= 0 || h <= 0 || w > 2048 || h > 2048) throw new InvalidDataException("Invalid sprite dimensions: " + l.Name);
            Check(wad, l.Position + 8, w * 4);
            string refPath = Path.Combine(privateRoot, reference.Replace('/', Path.DirectorySeparatorChar));
            string assetPath = Path.Combine(assetRoot, relative.Replace('/', Path.DirectorySeparatorChar));
            Directory.CreateDirectory(Path.GetDirectoryName(refPath));
            Directory.CreateDirectory(Path.GetDirectoryName(assetPath));
            int minX = w, minY = h, maxX = -1, maxY = -1;
            using (var image = new Bitmap(w, h, PixelFormat.Format32bppArgb)) {
                    for (int x = 0; x < w; ++x) {
                        int column = l.Position + I32(wad, l.Position + 8 + x * 4);
                        Check(wad, column, 1);
                        while (wad[column] != 255) {
                            Check(wad, column, 3);
                            int y = wad[column], length = wad[column + 1];
                            Check(wad, column + 3, length + 1);
                            for (int j = 0; j < length; ++j) {
                                if (y + j >= h) throw new InvalidDataException("Patch post outside canvas: " + l.Name);
                                int pi = wad[column + 3 + j] * 3 + paletteLump.Position;
                                image.SetPixel(x, y + j, Color.FromArgb(wad[pi], wad[pi + 1], wad[pi + 2]));
                                minX = Math.Min(minX, x); maxX = Math.Max(maxX, x);
                                minY = Math.Min(minY, y + j); maxY = Math.Max(maxY, y + j);
                            }
                            column += 4 + length;
                            Check(wad, column, 1);
                        }
                    }
                    if (!File.Exists(refPath) || force) image.Save(refPath, ImageFormat.Png);
            }
            if (maxX < minX || maxY < minY) throw new InvalidDataException("Empty sprite: " + l.Name);
            if (!File.Exists(assetPath) || force) {
                using (var image = new Bitmap(w, h, PixelFormat.Format32bppArgb))
                using (var g = Graphics.FromImage(image)) {
                    g.Clear(Color.Transparent);
                    g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.None;
                    // Geometry and colours are authored here; no reference pixels are read.
                    if (group == "axe") {
                        int bw = Math.Max(2, maxX - minX + 1), bh = Math.Max(2, maxY - minY + 1);
                        int cx = minX + bw / 2, cy = minY + bh / 2;
                        using (var handle = new Pen(Color.FromArgb(255, 42, 200, 162), Math.Max(2, bw / 14)))
                            g.DrawLine(handle, minX, maxY, cx + bw / 7, cy - bh / 6);
                        using (var blade = new SolidBrush(Color.FromArgb(255, 235, 174, 72)))
                            g.FillPolygon(blade, new[] { new Point(cx + bw / 7, cy - bh / 6), new Point(cx - bw / 9, minY), new Point(maxX, minY), new Point(maxX, cy) });
                    } else {
                        int bw = Math.Max(2, maxX - minX + 1), bh = Math.Max(2, maxY - minY + 1);
                        using (var body = new SolidBrush(Color.FromArgb(255, 60, 176, 191))) {
                            g.FillEllipse(body, minX, minY, bw, Math.Max(2, bh / 2));
                            g.FillRectangle(body, minX + bw / 8, minY + bh / 3, Math.Max(2, bw * 3 / 4), Math.Max(2, bh * 2 / 3));
                        }
                        using (var mark = new SolidBrush(Color.FromArgb(255, 245, 129, 72)))
                            g.FillRectangle(mark, minX + bw / 2 - 2, minY + bh / 3, Math.Max(2, bw / 8), Math.Max(2, bh / 8));
                    }
                    image.Save(assetPath, ImageFormat.Png);
                }
            }
            rows.Add(string.Join(",", set, l.Name, stem, reference, relative, w, h, left, top, runtime + l.Name.Substring(4), minX, minY, maxX, maxY));
        }
        string manifest = Path.Combine(privateRoot, "source-metadata.csv");
        File.WriteAllLines(manifest, rows, new UTF8Encoding(false));
        return manifest;
    }
}
