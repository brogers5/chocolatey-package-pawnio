# PawnIO

PawnIO is a scriptable universal kernel driver, allowing hardware access to a wide variety of programs. It uses the [Pawn](https://www.compuphase.com/pawn/pawn.htm) scripting language and the [PawnPP](https://github.com/namazso/PawnPP) interpreter. When installed, any software implementing PawnIO modules can use the driver to access or control hardware supported by one of the [official modules](https://github.com/namazso/PawnIO.Modules).

## Package Parameters

* `/NoShim` - Opt out of creating a shim for `PawnIOUtil`, and removes any existing shim.

## Package Notes

PawnIO's installer supports a couple additional arguments, which may be of interest to developers:

* `-unrestricted` - Installs the "unrestricted edition" which can load unsigned PawnIO modules. Note that this will install a test-signed driver, which requires [configuring Windows's Boot Configuration Data](https://learn.microsoft.com/windows-hardware/drivers/install/the-testsigning-boot-configuration-option) in order to start such drivers.
* `-debuginfo` - Include symbol files for each packaged component. These can be useful for debugging.

Any desired arguments can be appended to (or optionally overriding with the `--override-arguments` switch) the package's default install arguments with the `--install-arguments` option.

---

For future upgrade operations, consider opting into Chocolatey's `useRememberedArgumentsForUpgrades` feature to avoid having to pass the same arguments with each upgrade:

```shell
choco feature enable --name="'useRememberedArgumentsForUpgrades'"
```
