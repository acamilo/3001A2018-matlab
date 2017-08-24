# RBE3001 Matlab Template
This is template code for talking to the Default firmware

## Configure git
```
git config --global user.name "John Doe"
git config --global user.email johndoe@wpi.edu
```
## Clone Firmware
First create a new private repository and hold on to that git url.
```
git clone https://github.com/WPIRoboticsEngineering/RBE3001_Matlab.git
cd RBE3001_Matlab
```
## Set up your private repo
```
#Set your fresh clean Private repo here
git remote set-url origin git@github.com:MY_3001_PROJECT_GROUP/MY_PRIVATE_REPO_MATLAB.git
git checkout master
# Add the example RBE firmware as an upstream pull
git remote add RBE-UPSTREAM https://github.com/WPIRoboticsEngineering/RBE3001_Matlab.git
#this pushes the master baranch to your private repo
git push -u origin master
git remote -v
```
# Upstream updates
If the course staff needs to update or repair any system code or the dependant libraries, then you will need to run:
```
git pull RBE-UPSTREAM master
```

## Launch Matlab 

Start in the directory with your checked out code.

```
cd src
matlab
```
