#!/usr/bin/env bash
# @Author: Li Yudong
# @Date:   2019-11-28
# @Last Modified by:   Li Yudong
# @Last Modified time: 2019-11-28

TASK_NAME="csl"
MODEL_NAME="albert_xlarge_zh"
CURRENT_DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
export CUDA_VISIBLE_DEVICES="0"
export ALBERT_CONFIG_DIR=$CURRENT_DIR/albert_config
export ALBERT_PRETRAINED_MODELS_DIR=$CURRENT_DIR/prev_trained_model
export ALBERT_XLARGE_DIR=$ALBERT_PRETRAINED_MODELS_DIR/$MODEL_NAME
export GLUE_DATA_DIR=$CURRENT_DIR/../../glue/chineseGLUEdatasets

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
if [ ! -d $ALBERT_XLARGE_DIR ]; then
  mkdir -p $ALBERT_XLARGE_DIR
  echo "makedir $ALBERT_XLARGE_DIR"
fi
cd $ALBERT_XLARGE_DIR
if [ ! -f "albert_config_xlarge.json" ] || [ ! -f "vocab.txt" ] || [ ! -f "checkpoint" ] || [ ! -f "albert_model.ckpt.index" ] || [ ! -f "albert_model.ckpt.meta" ] || [ ! -f "albert_model.ckpt.data-00000-of-00001" ]; then
  rm *
  wget https://storage.googleapis.com/albert_zh/albert_xlarge_zh_177k.zip
  unzip albert_xlarge_zh_177k.zip
  rm albert_xlarge_zh_177k.zip
else
  echo "model exists"
fi
echo "Finish download model."

# run task
cd $CURRENT_DIR
echo "Start running..."
python run_classifier.py \
  --task_name=$TASK_NAME \
  --do_train=true \
  --do_eval=true \
  --data_dir=$GLUE_DATA_DIR/$TASK_NAME \
  --vocab_file=$ALBERT_CONFIG_DIR/vocab.txt \
  --bert_config_file=$ALBERT_CONFIG_DIR/albert_config_xlarge.json \
  --init_checkpoint=$ALBERT_XLARGE_DIR/albert_model.ckpt \
  --max_seq_length=256 \
  --train_batch_size=4 \
  --learning_rate=1e-5 \
  --num_train_epochs=3.0 \
  --output_dir=$CURRENT_DIR/${TASK_NAME}_output/
