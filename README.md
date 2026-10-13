# MC-private-production for h → aa → μμττ for Run 3
 
- First generate one MadGraph gridpack per Higgs mass (MASS_H) and Pseudoscalar mass (MASS_A)
- Follow GEN-SIM → DIGI-HLT → AOD → MiniAOD → NanoAOD chain on HTCondor.
  
## Setup and Configuration
 
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

Copy paths.sh.example to paths.sh and update the user specific paths

```
cp paths.sh.example paths.sh
```
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

Example for a single benchmark:
```
./submit_condor_gridpack_generation.sh ggh01_M125_Toa01a01_M5_Tomumutautau /PATH_TO_REPO/MC-private-production/cards/MH125/MA5 $PWD el8_amd64_gcc12 CMSSW_14_0_21
```
For convenience, one can use the following bash script, keeping the desired production modes, H mass and a masses.

```
#!/bin/bash                                                                                                                                                          

PROD_MODES="ggh01 vbfh01 wh01 zh01"

for MASS_H in 125 250 500 750 1000; do

    if [ "$MASS_H" -eq 125 ]; then
        MASS_A_LIST=("3.6" $(seq 4 1 21) "25")
    elif [ "$MASS_H" -eq 250 ]; then
        MASS_A_LIST=("3.6" $(seq 5 5 25) "50")
    elif [ "$MASS_H" -eq 500 ]; then
        MASS_A_LIST=("3.6" $(seq 5 5 30) "40" "50" "100")
    elif [ "$MASS_H" -eq 750 ]; then
        MASS_A_LIST=("3.6" $(seq 10 5 30) $(seq 40 10 80) "150")
    elif [ "$MASS_H" -eq 1000 ]; then
        MASS_A_LIST=("3.6" $(seq 10 5 30) $(seq 40 10 60) "80" "100" "200")
    fi

    for MASS_A in "${MASS_A_LIST[@]}"; do

        CARDS=/PATH_TO_REPO/MC-private-production/cards/MH"${MASS_H}"/MA"${MASS_A}"
        if [ ! -d "$CARDS" ]; then
            echo "Skipping: No cards found at $CARDS"
            continue
        fi

        for PROD in $PROD_MODES; do

            ./submit_condor_gridpack_generation.sh \
              "${PROD}_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau" \
              "$CARDS" \
              "$PWD" \
              el8_amd64_gcc12 \
              CMSSW_14_0_21

        done
    done
done
```

## Generate the cards
Copies cards from MH125/MA10 directory and make changes for the desired mass.

```
cd MC-private-production/cards/
```
For a specific benchmark
```
bash get_cards.sh <MASS_H> <MASS_A> #Example: bash get_cards.sh 125 5
```
For all benchmark in one go
```
bash get_all_cards.sh 
```

## Prepare the fragment
Copies MH125-MA10 fragment and and make changes for the desired mass. Finally copies the fragments to CMSSW directory.

```
cd YOURWORKDIRECTORY
cd /MC-private-production/fragments
```
For a specific benchmark
```
bash get_fragments.sh <MASS_H> <MASS_A> #Example: bash get_fragment.sh 125 5
```
For all benchmark in one go
```
bash get_fragments.sh
```
```
cd ../../CMSSW_14_0_21/src
cmsenv
scram b -j 8
```

## Submit jobs for event generation

```
cd /MC-private-production/condor
bash submit_jobs.sh <MASS_H> <MASS_A> <SAMPLETAG> #Example usage: ./submit_jobs.sh 125 5 vbfh01
```
Current sample tag list include: ggh01, vbfh01, wh01, zh01.

One can save the config for the first job by switching STORE_CONFIG=false to STORE_CONFIG=true in run_chain.sh.

Note: The DRPremix config can be large, so keep STORE_CONFIG=false in regular runs.

You can monitor the job status using ``condor_q``.
