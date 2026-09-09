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
## Generate cards for a specific mass point

```
cd MC-private-production/cards/
bash get_cards.sh <M_A mass> #Example: bash get_cards.sh 5
```
 ---
## Generate gridpacks

```
cd YOURWORKDIRECTORY
cd genproductions_scripts/bin/MadGraph5_aMCatNLO
```
Make sure your proxy is active
```
voms-proxy-info -timeleft
```
Submit a job to generate the gridopack
```
./submit_condor_gridpack_generation.sh \ ggh01_M125_Toa01a01_M<M_A-mass>_Tomumutautau \ ~/workspace/Run3/MC-private-production/cards/M<M_A-mass> \ $PWD \ el8_amd64_gcc12 \ CMSSW_14_0_21
```
For easier use you can use this bash script insetad of the last step:
```
#!/bin/bash

MASS=$1

CARDS=~/workspace/Run3/MC-private-production/cards/M${MASS}

if [ ! -d "$CARDS" ]; then
    echo "no cards at $CARDS"
    exit 1
fi

./submit_condor_gridpack_generation.sh \
  ggh01_M125_Toa01a01_M${MASS}_Tomumutautau \
  "$CARDS" \
  $PWD \
  el8_amd64_gcc12 \
  CMSSW_14_0_21
```

## Prepare the fragment
```
cd YOURWORKDIRECTORY
cd /MC-private-production/fragments
bash get_fragment.sh <M_A mass> #Example: bash get_fragment.sh 5
cd ../../CMSSW_14_0_21/src
cmsenv
scram b -j 8
```
## Submit jobs for event generation
```
cd /MC-private-production/condor
```

Modify the paths in this script to your working directory path before running it (``RELBASE`` and ``OUTBASE``).

```
bash submit_jobs.sh <M_A mass> #Example usage: ./submit_jobs.sh 5
```

You can monitor the job status using ``condor_q``.
