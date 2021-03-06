# `mobilizon-reshare`'s Guix channel

[![CI](https://github.com/fishinthecalculator/mobilizon-reshare-guix/actions/workflows/main.yml/badge.svg)](https://github.com/fishinthecalculator/mobilizon-reshare-guix/actions/workflows/main.yml)

## What is a Guix channel?

A [channel](https://guix.gnu.org/en/manual/devel/en/guix.html#Channels) is roughly the Guix equivalent of Ubuntu's PPAs or container registries. It's a software repository providing Guix package and service definitions.

This channels hosts all versions of [Mobilizon Reshare](https://github.com/Tech-Workers-Coalition-Italia/mobilizon-reshare) and a rudimental Mobilizon Reshare Guix service.

## Substitutes

Unfortunately currently there are no resources to distribute [substitutes](https://guix.gnu.org/en/manual/devel/en/guix.html#Substitutes). This means that Guix'll try and build Mobilizon Reshare and its dependencies locally on your machine. It's a one-time process, completely transparent with respect to the user and it shouldn't take more than a couple of minutes.

## Configure

To configure Guix for using this channel you need to create a `.config/guix/channels.scm` file with the following content:

``` scheme
(cons* (channel
        (name 'mobilizon-reshare)
        (url "https://github.com/fishinthecalculator/mobilizon-reshare-guix")
        (branch "main"))
       %default-channels)
```

Otherwise, if you already have a `.config/guix/channels.scm` you can simply prepend this channel to the preexisting ones:

``` scheme
(cons* (channel
        (name 'mobilizon-reshare)
        (url "https://github.com/fishinthecalculator/mobilizon-reshare-guix")
        (branch "main"))
       (channel
        (name 'nonguix)
        (url "https://gitlab.com/nonguix/nonguix")
        ;; Enable signature verification:
        (introduction
         (make-channel-introduction
          "897c1a470da759236cc11798f4e0a5f7d4d59fbc"
          (openpgp-fingerprint
           "2A39 3FFF 68F4 EF7A 3D29  12AF 6F51 20A0 22FB B2D5"))))
       %default-channels)
```

## Use a given mobilizon-reshare version

You can install mobilizon-reshare with:

```shell
guix install mobilizon-reshare
```

Otherwise you can spawn a shell with any given Mobilizon Reshare's version with:

``` shell
guix shell mobilizon-reshare@0.3.1
```

Or you can build a Docker image:

``` shell
guix pack -f docker mobilizon-reshare@0.1.0
```
