#!/usr/bin/env bash
# @Author: Li Yudong
# @Date:   2019-11-28
# @Last Modified by:   Li Yudong
# @Last Modified time: 2019-11-28

TASK_NAME="csl"
MODEL_NAME="chinese_xlnet_mid_L-24_H-768_A-12"
CURRENT_DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
export CUDA_VISIBLE_DEVICES="0"
export PRETRAINED_MODELS_DIR=$CURRENT_DIR/prev_trained_model
export XLNET_DIR=$PRETRAINED_MODELS_DIR/$MODEL_NAME
export GLUE_DATA_DIR=$CURRENT_DIR/../../glue/chineseGLUEdatasets

# install related packages
pip install sentencepiece --user

# download and unzip dataset
if [ ! -d $GLUE_DATA_DIR ]; then
  mkdir -p $GLUE_DATA_DIR
  echo "makedir $GLUE_DATA_DIR"
fi
cd $GLUE_DATA_DIR
if [ ! -d $TASK_NAME ]; then
  mkdir $TASK_NAME
  echo "makedir $GLUE_DATA_DIR/$TASK_NAME"
fi
cd $TASK_NAME
if [ ! -f "train.tsv" ] || [ ! -f "dev.tsv" ] || [ ! -f "test.tsv" ]; then
  rm *
  wget https://storage.googleapis.com/chineseglue/tasks/csl.zip
  unzip csl.zip
  rm csl.zip
else
  echo "data exists"
fi
echo "Finish download dataset."

# download model
if [ ! -d $XLNET_DIR ]; then
  mkdir -p $XLNET_DIR
  echo "makedir $XLNET_DIR"
fi
cd $XLNET_DIR
if [ ! -f "xlnet_config.json" ] || [ ! -f "spiece.model" ] || [ ! -f "xlnet_model.ckpt.index" ] || [ ! -f "xlnet_model.ckpt.meta" ] || [ ! -f "xlnet_model.ckpt.data-00000-of-00001" ]; then
  rm *
  wget -c https://storage.googleapis.com/chineseglue/pretrain_models/chinese_xlnet_mid_L-24_H-768_A-12.zip
  unzip chinese_xlnet_mid_L-24_H-768_A-12.zip
  rm chinese_xlnet_mid_L-24_H-768_A-12.zip
else
  echo "model exists"
fi
echo "Finish download model."

# run task
cd $CURRENT_DIR
echo "Start running..."
python run_classifier.py \
    --spiece_model_file=${XLNET_DIR}/spiece.model \
    --model_config_path=${XLNET_DIR}/xlnet_config.json \
    --init_checkpoint=${XLNET_DIR}/xlnet_model.ckpt \
    --task_name=$TASK_NAME \
    --do_train=True \
    --do_eval=True \
    --eval_all_ckpt=False \
    --uncased=False \
    --data_dir=$GLUE_DATA_DIR/$TASK_NAME \
    --output_dir=$CURRENT_DIR/${TASK_NAME}_output/ \
    --model_dir=$CURRENT_DIR/${TASK_NAME}_output/ \
    --train_batch_size=4 \
    --eval_batch_size=4 \
    --num_hosts=1 \
    --num_core_per_host=1 \
    --num_train_epochs=3 \
    --max_seq_length=256 \
    --learning_rate=1e-5 \
    --save_steps=1000 \
    --use_tpu=False
