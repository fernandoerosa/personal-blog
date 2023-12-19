#!/bin/bash
    sudo chmod 777 -R storage
    sudo chmod 777 -R storage/framework/views
    sudo chmod 777 -R bootstrap
    docker-compose up -d --build
