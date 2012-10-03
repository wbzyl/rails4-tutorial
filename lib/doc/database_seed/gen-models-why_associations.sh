#! /bin/bash

rails g model Author first_name last_name
rails g model Article title isbn pub_date                   # resztę opuszczamy          8-(
rails g model Bibinfo author:references article:references  # jakieś pomysły na atrybuty 8-)
