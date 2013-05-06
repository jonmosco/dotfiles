Future home for my dotfiles.
===============================================================================

TODO:
- Describe structure and direction
- Describe intallation [DONE]
- Add dircolors 
- Add iTerm2 Settings

Motivation:
-------------------------------------------------------------------------------

I found myself having to administer several Unix servers and had one-offs for 
configuration on almost all but one.  I decieded to version my dotfiles and 
put them into subversion to be able to have consistency across all the servers
I log into.  Now, having to administer several remote sites I needed to have a 
remotely accessable repository, hence this github repo!  

Dependencies:
-------------------------------------------------------------------------------
Linux:
- Bash
- XTerm
- Mutt (Provided you will want to use mutt as your MUA)

Mac OSX: 
- iTerm2
- Homebrew

Vim Plugins:
- NERDtree: https://github.com/scrooloose/nerdtree
- Solarized Theme: https://github.com/altercation/solarized
- Syntastic: https://github.com/scrooloose/syntastic
- Tabular: https://github.com/godlygeek/tabular

All other dependencies are fulfilled by dotlink3.sh

Installation:
-------------------------------------------------------------------------------

- Checkout the git repo: $ git clone https://github.com/jonmosco/dotfiles.git .dotfiles
- Run dotlink3.sh to create symlinks: 

        $ cd .dotfiles 
        $ ./dotlink3.sh

- Answer questions regarding email setup.
- Logout and log back in
- Enjoy (or criticize) 
