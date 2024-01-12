#!/bin/bash
sudo docker logs rancher-center 2>&1 | grep "Bootstrap Password:"