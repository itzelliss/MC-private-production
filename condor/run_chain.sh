#!/bin/bash
#
# run_chain.sh — full GEN-SIM → NanoAOD chain for one condor job
#
# Usage:  run_chain.sh <job_index> <mass>
# Example: run_chain.sh <job_index> M4
#
# Runs entirely on the worker node's local scratch ($_CONDOR_SCRATCH_DIR).
# Only MiniAOD and NanoAOD are copied out; the large intermediates
# (GEN-SIM, DIGI-RAW, AOD) are left behind and die with the job.
#
# Campaign: RunIII2024Summer24
#   GEN-SIM / DR / AOD : CMSSW_14_0_21   140X_mcRun3_2024_realistic_v26
#   MiniAOD            : CMSSW_15_0_4    140X_mcRun3_2024_realistic_v26
#   NanoAOD            : CMSSW_15_0_6    150X_mcRun3_2024_realistic_v2
#   arch               : el8_amd64_gcc12
#

set -e
set -o pipefail

# ---------------------------------------------------------------- settings

JOBID=$1
MASS_H=$2
MASS_A=$3
SAMPLETAG=$4
NEVENTS=100

# Seed must be unique per job and NON-ZERO.
# (A zero seed is rejected by RandomNumberGeneratorService.)
MASS_NUM=${MASS_A#M}
SEED=$(( 100000 + MASS_NUM * 1000 + JOBID ))

CAMPAIGN=RunIII2024Summer24
SAMPLE=${SAMPLETAG}_${MASS_H}_Toa01a01_${MASS_A}_Tomumutautau

RELBASE=/afs/cern.ch/work/s/sbaradia/public/PseudoscalarSearch_Run3/CMSSW
REL_GS=${RELBASE}/CMSSW_14_0_21
REL_MINI=${RELBASE}/CMSSW_15_0_4
REL_NANO=${RELBASE}/CMSSW_15_0_6

OUTBASE=/eos/user/s/sbaradia/PseudoScalar_Run3/SignalProduction/${CAMPAIGN}/${MASS_H}/${SAMPLETAG}/${MASS_A}

FRAGMENT=Configuration/GenProduction/python/${SAMPLE}_13p6TeV_fragment.py

GT_140=140X_mcRun3_2024_realistic_v26
GT_150=150X_mcRun3_2024_realistic_v2
ERA=Run3_2024
HLT_MENU=2024v14
PREMIX="dbs:/Neutrino_E-10_gun/RunIIISummer24PrePremix-Premixlib2024_140X_mcRun3_2024_realistic_v26-v1/PREMIX"

export SCRAM_ARCH=el8_amd64_gcc12

# ---------------------------------------------------------------- helpers

log () { echo "[$(date '+%H:%M:%S')] === $* ==="; }

# Enter a CMSSW release cleanly. Each step needs its own environment, and
# you cannot cmsenv one release on top of another — so we unset first.
use_release () {
    local rel=$1
    unset CMSSW_BASE CMSSW_RELEASE_BASE CMSSW_VERSION
    cd "${rel}/src"
    eval $(scram runtime -sh)
    cd "${WORKDIR}"
    log "using ${CMSSW_VERSION}"
}

# ---------------------------------------------------------------- setup

WORKDIR=${_CONDOR_SCRATCH_DIR:-$(mktemp -d)}
CONFIGBASE=/afs/cern.ch/work/s/sbaradia/public/PseudoscalarSearch_Run3/MCProduction/MC-private-production/configs/${CAMPAIGN}
mkdir -p "${CONFIGBASE}"

cd "${WORKDIR}"

log "job ${JOBID}, seed ${SEED}, ${NEVENTS} events"
log "host $(hostname), scratch ${WORKDIR}"
df -h "${WORKDIR}" | tail -1

source /cvmfs/cms.cern.ch/cmsset_default.sh

# The premix pileup library is read over xrootd and needs a valid proxy.
# Condor transfers it in; point X509 at the local copy.
if [ -f "${WORKDIR}/x509up" ]; then
    export X509_USER_PROXY=${WORKDIR}/x509up
fi
voms-proxy-info -exists -valid 0:10 || {
    echo "ERROR: no valid grid proxy — the DIGI step will fail" >&2
    exit 1
}

# ---------------------------------------------------------------- 1. GEN-SIM

use_release "${REL_GS}"

cmsDriver.py "${FRAGMENT}" \
  --python_filename GENSIM_cfg.py \
  --eventcontent RAWSIM --datatier GEN-SIM \
  --fileout file:GENSIM.root \
  --conditions ${GT_140} \
  --beamspot DBrealistic \
  --customise Configuration/DataProcessing/Utils.addMonitoring \
  --customise_commands "process.RandomNumberGeneratorService.externalLHEProducer.initialSeed=int(${SEED})" \
  --step LHE,GEN,SIM --geometry DB:Extended --era ${ERA} \
  --no_exec --mc -n ${NEVENTS}

log "running GEN-SIM"
if [ "${JOBID}" -eq 0 ]; then
    cp GENSIM_cfg.py "${CONFIGBASE}/GENSIM_${MASS_H}_${MASS_A}.py"
fi
cmsRun GENSIM_cfg.py

# ---------------------------------------------------------------- 2. DIGI→HLT

cmsDriver.py \
  --python_filename DR_cfg.py \
  --eventcontent PREMIXRAW --datatier GEN-SIM-RAW \
  --fileout file:DR.root \
  --filein file:GENSIM.root \
  --conditions ${GT_140} \
  --customise Configuration/DataProcessing/Utils.addMonitoring \
  --step DIGI,DATAMIX,L1,DIGI2RAW,HLT:${HLT_MENU} \
  --procModifiers premix_stage2 \
  --datamix PreMix \
  --pileup_input "${PREMIX}" \
  --geometry DB:Extended --era ${ERA} \
  --no_exec --mc -n ${NEVENTS}

log "running DIGI-HLT (slowest step)"
if [ "${JOBID}" -eq 0 ]; then
    cp DR_cfg.py "${CONFIGBASE}/DR_${MASS_H}_${MASS_A}.py"
fi
cmsRun DR_cfg.py
rm -f GENSIM.root          # reclaim scratch as we go

# ---------------------------------------------------------------- 3. AOD

cmsDriver.py \
  --python_filename AOD_cfg.py \
  --eventcontent AODSIM --datatier AODSIM \
  --fileout file:AOD.root \
  --filein file:DR.root \
  --conditions ${GT_140} \
  --customise Configuration/DataProcessing/Utils.addMonitoring \
  --step RAW2DIGI,L1Reco,RECO,RECOSIM \
  --geometry DB:Extended --era ${ERA} \
  --no_exec --mc -n ${NEVENTS}

log "running RECO"
if [ "${JOBID}" -eq 0 ]; then
    cp AOD_cfg.py "${CONFIGBASE}/AOD_${MASS_H}_${MASS_A}.py"
fi
cmsRun AOD_cfg.py
rm -f DR.root

# ---------------------------------------------------------------- 4. MiniAOD

use_release "${REL_MINI}"

cmsDriver.py \
  --python_filename MINI_cfg.py \
  --eventcontent MINIAODSIM --datatier MINIAODSIM \
  --fileout file:MINI.root \
  --filein file:AOD.root \
  --conditions ${GT_140} \
  --customise Configuration/DataProcessing/Utils.addMonitoring \
  --step PAT \
  --geometry DB:Extended --era ${ERA} \
  --no_exec --mc -n ${NEVENTS}

log "running PAT"
if [ "${JOBID}" -eq 0 ]; then
    cp MINI_cfg.py "${CONFIGBASE}/MINI_${MASS_H}_${MASS_A}.py"
fi
cmsRun MINI_cfg.py
rm -f AOD.root

# ---------------------------------------------------------------- 5. NanoAOD

use_release "${REL_NANO}"

# NANOAODSIM (not NANOEDMAODSIM) gives flat Muon_pt / GenPart_* branches
# that uproot can read directly.
cmsDriver.py \
  --python_filename NANO_cfg.py \
  --eventcontent NANOAODSIM --datatier NANOAODSIM \
  --fileout file:NANO.root \
  --filein file:MINI.root \
  --conditions ${GT_150} \
  --customise Configuration/DataProcessing/Utils.addMonitoring \
  --step NANO --scenario pp --era ${ERA} \
  --no_exec --mc -n ${NEVENTS}

log "running NANO"
if [ "${JOBID}" -eq 0 ]; then
    cp NANO_cfg.py "${CONFIGBASE}/NANO_${MASS_H}_${MASS_A}.py"
fi
cmsRun NANO_cfg.py

# ---------------------------------------------------------------- stage out

log "staging out"
mkdir -p "${OUTBASE}/miniaod" "${OUTBASE}/nanoaod"

cp MINI.root "${OUTBASE}/miniaod/MINI_${JOBID}.root"
cp NANO.root "${OUTBASE}/nanoaod/NANO_${JOBID}.root"

ls -lh "${OUTBASE}/nanoaod/NANO_${JOBID}.root"
log "job ${JOBID} finished OK"
