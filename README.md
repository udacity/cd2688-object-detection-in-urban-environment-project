# Object detection in an urban environment

In this project, you will learn how to train an object detection model using the [Tensorflow Object Detection API](https://tensorflow-object-detection-api-tutorial.readthedocs.io/en/latest/index.html) and [AWS Sagemaker](https://aws.amazon.com/sagemaker/). At the end of this project, you will be able to generate videos such as the one below. 

<p align="center">
    <img src="data/animation.gif" alt="drawing" width="600"/>
</p>

## Installation

Refer to the **Setup Instructions** page in the classroom to setup the Sagemaker Notebook instance required for this project.

>Note: The `conda_tensorflow2_p310` kernel contains most of the required packages for this project. The notebooks contain lines for manual installation when required.

## Usage

This repository contains two notebooks:
* [1_train_model](1_model_training/1_train_model.ipynb): this notebook is used to launch a training job and create tensorboard visualizations. 
* [2_deploy_model](2_run_inference/2_deploy_model.ipynb): this notebook is used to deploy your model, run inference on test data and create a gif similar to the one above.

First, run `1_train_model.ipynb` to train your model. Once the training job is complete, run `2_deploy_model.ipynb` to deploy your model and generate the animation.

Each notebook contains the instructions for running the code, as well the requirements for the writeup. 
>Note: Only the first notebook requires a write up. 

## Troubleshooting

**SageMaker SDK errors** (for example `No module named 'sagemaker.estimator'`, `module 'sagemaker' has no attribute 'get_execution_role'` or `No module named 'sagemaker.train'`)

The notebooks use the SageMaker Python SDK **v3** (`ModelTrainer` for training, and the `Model`, `EndpointConfig` and `Endpoint` resources from `sagemaker.core` for deployment). They need Python 3.10 or later (the default `conda_python3` kernel on SageMaker notebook instances). Run the install cell at the top of the notebook, restart the kernel (**Kernel > Restart**), and run the notebook from the top again. The version check cell must print a version that starts with `3.`.

`No module named 'sagemaker.estimator'` or `TensorFlowModel` errors mean that you are running an older copy of the notebooks, written for SDK v2. Run `git pull` in the repository folder to get the latest version.

**S3 `AccessDenied` when launching the training job**

`tensorboard_s3_prefix` must point to a bucket in your own AWS account. By default the notebook uses your SageMaker default bucket.

**Deployment fails or doesn't finish**

`2_deploy_model.ipynb` creates its own endpoint on an `ml.g4dn.xlarge` instance, which usually takes 5 to 15 minutes. If it fails or times out:
* check that `model_artifact` is the full S3 path of the `model.tar.gz` produced by a **Completed** training job
* check that your quota for `ml.g4dn.xlarge for endpoint usage` is at least 1 (**Service Quotas > Amazon SageMaker** in the AWS console)
* read the failure reason under **Inference > Endpoints** and the CloudWatch logs of the endpoint

Delete the failed endpoint, as well as its endpoint configuration and model, before you try again.

**Remember to delete your endpoint** when you are done (last cell of `2_deploy_model.ipynb`). Endpoints are billed for every hour they run.

## Useful links
* The Tensorflow Object Detection API tutorial is a great resource to debug your code. This [section](https://tensorflow-object-detection-api-tutorial.readthedocs.io/en/latest/training.html#configure-the-training-pipeline) in particular will teach you how to edit the `pipeline.config` file to update
your training job.

* [This blog post](https://aws.amazon.com/blogs/machine-learning/training-and-deploying-models-using-tensorflow-2-with-the-object-detection-api-on-amazon-sagemaker/) teaches how to label data, train and deploy a model with the Tensorflow Object Detection API and AWS Sagemaker.
