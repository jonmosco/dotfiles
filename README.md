Future home for my dotfiles.
===============================================================================

TODO:
- Describe structure and direction
- Describe intallation
- Add dircolors 

Dependencies:
-------------------------------------------------------------------------------
- Bash
- Xterm
- Mutt (Provided you will want to use mutt as your MUA)
- Git Prompt: https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh
- Solarized theme: http://ethanschoonover.com/solarized

Motivation:
-------------------------------------------------------------------------------

I found myself having to administer several Unix servers and had one-offs for 
configuration on almost all but one.  I decieded to version my dotfiles and 
put them into subversion to be able to have consistency across all the servers
I log into.  Now, having to administer several remote sites I needed to have a 
remotely accessable repository, hence this github repo!  

Installation:
-------------------------------------------------------------------------------
Vim customization relies on several plugins:
- https://github.com/scrooloose/syntastic
- Solarized Vim: https://github.com/altercation/vim-colors-solarized

Follow the installation instructions in both of those links

- Checkout the git repo: $ git clone https://github.com/jonmosco/dotfiles.git .dotfiles
- Run dotlink3.sh to create symlinks: 

        $ cd .dotfiles 
        $ ./dotlink3.sh

- Answer questions regarding email setup.
- Logout and log back in
- Enjoy (or criticize) 
