// =============================================================
// Knurled vase - parametric OpenSCAD version of the Fusion 360 model
//
// Pattern: a checkerboard of alternating outset / inset 4-sided
// pyramids ("diamond knurl") wrapped around a cylinder.
//
// Reverse-engineered from the original .step:
//   radius        = 30 mm
//   sides         = 27 pairs  (54 pyramids, one every 6.67 deg)
//   one cell      = 3.489 mm tall (square cells)
//   knurl depth   = ~0.95 mm radial
//
// New compared to Fusion: `rows` controls vertical repetition.
// =============================================================

/* [Vase shape] */

// Base cylinder radius (mm)
radius = 50;            // [10:1:100]

// Pyramid pairs around the circumference (doubled internally so the
// alternating in/out checkerboard always closes cleanly at the seam)
sides = 13;             // [4:1:40]

// Pyramid rows stacked vertically
rows = 18;              // [1:1:80]

/* [Knurl pattern] */

// Radial outset / inset of each pyramid (mm)
knurl_depth = 2;        // [0:0.05:5]

// Cell height / circumferential width; 1.0 = square cells
cell_aspect = 1;      // [0.25:0.05:3]

/* [Floor] */

// Solid floor thickness (mm); 0 = open bottom
floor_thick = 0;        // [0:0.5:10]

/* [Hidden] */

$fn = 64;               // only affects the floor cylinder

// -------------------- Derived --------------------
_sides = 2 * sides;     // doubled so the checkerboard parity always closes
cell_w = 2 * radius * sin(180 / _sides);
cell_h = cell_w * cell_aspect;

echo(str("Vase height = ", rows * cell_h, " mm / ",
         round(rows * cell_h / 25.4 * 100) / 100, " in",
         "  (cell = ", cell_w, " x ", cell_h, " mm)"));

// -------------------- Geometry --------------------
function corner_pt(i, j) = [
    radius * cos(360 * i / _sides),
    radius * sin(360 * i / _sides),
    j * cell_h
];

function apex_pt(i, j) =
    let(
        ang  = 360 * (i + 0.5) / _sides,
        sgn  = (((i + j) % 2) == 0) ? +1 : -1,   // checkerboard
        r    = radius + sgn * knurl_depth
    )
    [r * cos(ang), r * sin(ang), (j + 0.5) * cell_h];

// Index helpers (i wraps around the cylinder)
function ci(i, j) = (i % _sides) * (rows + 1) + j;
function ai(i, j) = _sides * (rows + 1) + (i % _sides) * rows + j;

corner_points = [
    for (i = [0 : _sides - 1], j = [0 : rows])
        corner_pt(i, j)
];

apex_points = [
    for (i = [0 : _sides - 1], j = [0 : rows - 1])
        apex_pt(i, j)
];

all_points = concat(corner_points, apex_points);

// Each cell = 4 triangles from its apex out to the 4 base corners.
// Same winding for outset and inset; the apex's radial sign already flips
// the geometry, and using a consistent vertex order keeps every shared
// edge traversed in opposite directions (manifold requirement).
cell_faces = [
    for (i = [0 : _sides - 1], j = [0 : rows - 1]) each
        let(
            bl = ci(i,     j    ),
            br = ci(i + 1, j    ),
            tr = ci(i + 1, j + 1),
            tl = ci(i,     j + 1),
            ap = ai(i,     j    )
        )
        [[ap, bl, br], [ap, br, tr], [ap, tr, tl], [ap, tl, bl]]
];

// Close the bottom and top of the knurled shell with N-gon fans.
// Bottom face normal must point -Z (outward); top must point +Z.
bottom_faces = [
    for (i = [1 : _sides - 2])
        [ci(0, 0), ci(i + 1, 0), ci(i, 0)]
];

top_faces = [
    for (i = [1 : _sides - 2])
        [ci(0, rows), ci(i, rows), ci(i + 1, rows)]
];

all_faces = concat(cell_faces, bottom_faces, top_faces);

// -------------------- Render --------------------
module knurled_vase() {
    union() {
        if (floor_thick > 0)
            translate([0, 0, -floor_thick])
                cylinder(r = radius, h = floor_thick, $fn = _sides);
        polyhedron(points = all_points, faces = all_faces, convexity = 10);
    }
}

knurled_vase();
