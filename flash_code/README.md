# Flash decompiler

Open the .swf with this:
* https://github.com/jindrapetrik/jpexs-decompiler

Get the latest release from the repository, then use the files in ~this repository~ ./flash_code/flash_prerequisites to finish the setup of jpexs. Go to settings > advanced settings > Paths, and fill in:

- 1\) Flash player projector: with flashplayer_32_sa.exe
- 2\) Flash player projector content debugger: with flashplayer_32_sa_debug.exe
- 3\) Player Global : with playerglobal32_0.swc
- 6\) AIR Library : with airglobal.swc (maybe not needed?)

Now you can load achtung.swf (and Run/Debug).
<br /><br />

# References

### Flash API reference (beware of some AIR library specific classes):
* https://airsdk.dev/reference


### More obscure references (may not be needed):
* https://www.m2osw.com/swf_tags
* https://jindrapetrik.github.io/as3_pcode_instructions.en.html