# MC-private-production
 
Private CMS signal samples for h → aa → μμττ for Run 3.
 
One MadGraph gridpack per pseudoscalar mass, then the full GEN-SIM → DIGI-HLT → AOD → MiniAOD → NanoAOD chain on HTCondor.
 
---
 
## Setup
 
Log in to an **el8** node — the gridpacks and all three CMSSW releases are built for `el8_amd64_gcc12`:
 
```
ssh YOURUSERNAME@lxplus8.cern.ch
```
 
Add this line to your `.bashrc` in your lxplus root directory:
 
```
export X509_USER_PROXY=$HOME/tmp/x509up
```
 
Then initialize your grid proxy. 
 
```
voms-proxy-init --voms cms --valid 192:00
```
 
Create your working directory and enter it:
 
```
cd YOURWORKDIRECTORY
```
 
Clone this repository and the CMS generator scripts. `genproductions_scripts` is the official repo that builds gridpacks.
 
```
git clone git@github.com:itzelliss/MC-private-production.git
git clone https://gitlab.cern.ch/cms-gen/genproductions_scripts.git
```
 
Set up the three CMSSW releases. Do this from a **clean shell** and run each `cmsrel` in turn — you cannot `cmsenv` one release on top of another:
 
```
export SCRAM_ARCH=el8_amd64_gcc12
source /cvmfs/cms.cern.ch/cmsset_default.sh
cmsrel CMSSW_14_0_21     # GEN-SIM, DIGI-HLT, AOD
cmsrel CMSSW_15_0_4      # MiniAOD
cmsrel CMSSW_15_0_6      # NanoAOD
```
 
---
 
