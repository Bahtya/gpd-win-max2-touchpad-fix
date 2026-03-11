# GPD WIN Max2 触控板排查总结

## 设备信息

| 项目 | 详情 |
|------|------|
| 电脑型号 | GPD WIN Max2 |
| 触控板型号 | Goodix GXTP7385 |
| 连接方式 | I2C (通过 AMD I2C Controller) |
| 设备ID | `ACPI\GXTP7385\3&C8C3232&0` |
| 操作系统 | Windows 11 22H2 (22621) |

---

## 排查过程

### 1. 硬件识别

使用 `wmic` 命令识别触控板设备：

```cmd
wmic path win32_PnPEntity where "name like '%Goodix%' or name like '%I2C%'" get name, status, deviceid
```

**发现结果:**
- I2C 控制器: `ACPI\AMDI0010` (AMD I2C Controller，有3个实例)
- 触控板: `ACPI\GXTP7385` (Goodix 触控板)
- HID 设备: 多个 `HID\GXTP7385` 相关设备

### 2. 问题根因分析

Goodix GXTP7385 是 I2C 触控板，Windows 会通过 USB/I2C 选择性挂起功能来节能。

**问题表现:**
- 触控板移动正常，但点击偶尔失效
- 睡眠唤醒后触控板不响应
- 需要重启电脑才能恢复

**根本原因:**
Windows 电源管理关闭了 I2C HID 设备，导致触控板点击功能失效。

### 3. 解决方案设计

#### Windows 修复: 禁用 USB 选择性挂起
...
#### Linux 修复: 禁用 Runtime Power Management

在 Linux (Bazzite/Fedora) 中，问题的本质相同：内核的运行时电源管理 (Runtime PM) 会挂起 I2C 控制器。

**udev 规则定义:**
```udev
ACTION=="add", SUBSYSTEM=="i2c", ATTR{name}=="PNP0C50:00", ATTR{power/control}="on"
ACTION=="add", SUBSYSTEM=="i2c", KERNELS=="AMDI0010:00", ATTR{power/control}="on"
```

**执行脚本 (`fix_touchpad.sh`):**
1. 创建 `/etc/udev/rules.d/99-gpd-win-max2-touchpad.rules`
2. 重新加载 udev 规则并触发：`udevadm control --reload-rules && udevadm trigger`
3. 实时写入 `/sys/devices/platform/AMDI0010:00/power/control` 为 `on`

---

## 使用的工具和技术

### 工具
- `wmic` - Windows Management Instrumentation 命令行
- `powercfg` - 电源配置命令
- `reg` - 注册表编辑
- `sc` - 服务控制
- `PowerShell` - 自动化脚本

### 关键命令

**设备查询:**
```cmd
wmic path win32_PnPEntity get name, status, deviceid
```

**电源设置 GUID:**
- USB 设置: `2a737441-1930-4402-8d77-b2bebba308a3`
- 选择性挂起: `48672f38-7a9a-4bb2-8bf8-3d85be19de4e`

**服务控制:**
```cmd
sc config TabletInputService start= auto
sc start TabletInputService
```

---

## 最终交付文件

| 文件 | 说明 |
|------|------|
| `FixTouchpad.bat` | 主修复工具，自动请求管理员权限并执行所有修复 |
| `RestartTouchpad.bat` | 快速重启工具，用于触控板失效时临时修复 |
| `verify_fix.ps1` | 验证脚本，检查修复是否成功应用 |
| `START_HERE.md` | 用户使用说明 |
| `TROUBLESHOOTING_SUMMARY.md` | 本文档 - 排查过程总结 |

---

## 技术参考

### Goodix 触控板

Goodix (汇顶科技) 是中国触控芯片制造商，其触控板广泛用于小型笔记本电脑。

GXTP7385 是 I2C 接口的触控板，需要：
- 正确的 I2C 驱动 (AMD I2C Controller)
- HID 驱动 (Windows 内置)
- 电源管理配置正确

### Windows 电源管理

USB 选择性挂起 (USB Selective Suspend) 是 Windows 的节能功能：
- 关闭不活动的 USB 设备
- 可能导致 I2C 设备响应延迟
- 对触控板等输入设备影响最大

### 电源设置 GUID 参考

```
2a737441-1930-4402-8d77-b2bebba308a3  -> USB Settings
48672f38-7a9a-4bb2-8bf8-3d85be19de4e  -> USB Selective Suspend
501a4d13-42af-4429-9fd1-a8218c268e20  -> PCI Express
ee12f906-d277-404b-b6da-e5fa70619083  -> PCIe Link State Power Management
0012ee47-9041-4b5d-9b77-535fba8b1442  -> Hard Disk
6738e2c4-e8a5-4a42-b16a-e040e769756e  -> Turn off hard disk after
```

---

## 已知问题和限制

1. **需要管理员权限** - 所有修复都需要管理员权限
2. **可能需要重启** - 某些更改需要重启才能生效
3. **可能影响电池续航** - 禁用节能设置会略微增加耗电
4. **BIOS 更新** - GPD 可能会发布固件更新彻底解决此问题

---

## 后续建议

如果修复后问题仍存在：

1. 检查 GPD 官网是否有 BIOS/驱动更新
2. 在设备管理器中卸载并重装触控板驱动
3. 检查是否有第三方软件冲突
4. 联系 GPD 技术支持
