# Parametric Diamond Faceted Vase

A parametric OpenSCAD vase wrapped in a checkerboard of alternating outset / inset 4-sided pyramids ("alternating diamond knurl").

Available on MakerWorld: <https://makerworld.com/en/models/2817425-parametric-diamond-faceted-vase#profileId-3136959>

## Parameters

| Parameter      | Default | Description                                                              |
| -------------- | ------- | ------------------------------------------------------------------------ |
| `radius`       | 50 mm   | Base cylinder radius                                                     |
| `sides`        | 13      | Pyramid pairs around the circumference (doubled internally for parity)   |
| `rows`         | 18      | Pyramid rows stacked vertically                                          |
| `knurl_depth`  | 2 mm    | Radial outset / inset of each pyramid                                    |
| `cell_aspect`  | 1.0     | Cell height / circumferential width (1.0 = square cells)                 |
| `floor_thick`  | 0 mm    | Solid floor thickness (0 = open bottom)                                  |

## Height

Height isn't a direct slider — it's the number of `rows` times the per-cell height:

```
height = rows × 2 × radius × sin(180 / (2 × sides)) × cell_aspect
```

At the defaults (`radius = 50`, `sides = 13`, `cell_aspect = 1.0`), each row adds ~12.05 mm, so `rows = 18` gives ~216.97 mm (8.54″). The .scad echoes the computed height to the OpenSCAD console on every recompile.
