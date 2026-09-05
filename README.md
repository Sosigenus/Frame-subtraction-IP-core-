# IP-core frame subtraction
### **Highly parameterizable Frame Subtraction IP-core for video processing with selectable AXI4-Full or AXI4-Stream interfaces**

## Overview

The **Frame Subtraction IP-core** is designed for real-time video processing in FPGA systems. It performs pixel-wise subtraction between two consecutive frames, allowing detection of changes, motion, or temporal differences in a video stream.

## Parameters

| Parameter           | Type    | Default        | Description                                      |
|---------------------|---------|----------------|--------------------------------------------------|
| `INTERFACE_TYPE`    | String  | `"AXI_STREAM"` | Input interface: `"AXI4_FULL"` or `"AXI_STREAM"` |
| `S_AXI_ADDR_WIDTH`  | Integer | `32`           | Address width for AXI4-Full interface            |
| `S_AXI_DATA_WIDTH`  | Integer | `128`          | Data width for AXI input                         |
| `M_AXIS_DATA_WIDTH` | Integer | `128`          | Data width for AXI-Stream output                 |
| `WIDTH_FRAME`       | Integer | `1920`         | Frame width in pixels                            |
| `HEIGHT_FRAME`      | Integer | `1080`         | Frame height in pixels                           |

## Architecture

`top_frame_subtraction`<hr>
`axif2buffer`/`axis2buffer`<hr>
`buffer_videostream`<hr>
`frame_subtraction`<hr>