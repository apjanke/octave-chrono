Chrono Release Checklist
=======================

* Run all the tests.
  * `make test`, duh.
  * Wouldn't hurt to do `make test`/`make clean`/`git status`/manual-cleanup a few times, just to be sure.
* Update the version number and date in `DESCRIPTION` and `doc/chrono.texi.in` and rebuild the documentation.
  * `(cd doc; make maintainer-clean; make all)`
  * Manually examine any local changes and decide if they can/should be discarded. Changes to DVI/PDF files are probably insignificant; changes to HTML files need scrutiny.
* Update the installation instructions in README to use the upcoming release tarball URL.
  * Format is: `https://github.com/apjanke/octave-addons-chrono/releases/download/v<version>/chrono-<version>.tar.gz`
* Commit all the files changed by the above steps.
  * Use form: `git commit -a -m "Cut release v<version>"`
* Create a git tag amd push it and the changes to GitHub.
  * `git tag v<version>`
  * `git push; git push --tags`
* Make sure your repo is clean: `git status` should show no local changes
* `make dist`
* Create a new GitHub release from the tag.
  * Just use `<version>` as the name for the release.
  * Upload the dist tarball as a file for the release.
* Test installing the release using `pkg install` against the new release URL.
  * On macOS.
  * On Ubuntu.
  * *sigh* I suppose, on Windows.
  * Try this by copy-and-pasting the `pkg install` example from the 
    [live README page](https://github.com/apjanke/octave-addons-chrono/blob/master/README.md) 
    on the GitHub repo. This makes sure the current install instructions are correct.
    * Don't fuckin' short-circuit this and just edit an entry from your Octave command history! Open GitHub in a browser and actually copy-and-paste it!
    * I wish there there was a `pkg test <package>` command to run all the BISTs from a package.
    * Barring that, do a manual `pkg ls`, copy and paste the Chrono package path into a `cd('<package_path>')`, and then do `runtests .`
  * Aw crap, looks like Octave 4.2 and earlier don't support URLs as arguments to `pkg install`; only filenames?
    * Sigh. Manually download the release tarball (with `wget`, using the URL copy-and-pasted from the live project README page) and install from there.
      * In Octave, you need to use `system('wget ...')`, not `!wget ...`.
    * This affects both Ubuntu 16.x Xenial and Ubuntu 18.04 Bionic (Octave 4.2.2).
  * ANY failure borks the release once we get near 1.0!
    * Let ‘em go for now so we can get code out for review.
    * TODO: Decide on policy on what to do then. Can git tags/GitHub Releases be removed?
* Post an announcement comment on the "Updates" issue.
* Post an announcement on the [Savannah bug for datetime support](https://savannah.gnu.org/bugs/index.php?47032).
* Update version number in `DESCRIPTION` and `doc/chrono.texi.in` to SNAPSHOT of next minor version.

* If there were any problems following these instructions exactly as written, report it as a bug.



