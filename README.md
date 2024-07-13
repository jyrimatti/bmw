# Homekit.sh plugin for BMW cars

Prerequisites
-------------
- get a computer (e.g. a server or a Raspberry Pi)
- install [Nix](https://nixos.org/download/)
- install [Homekit.sh](https://github.com/jyrimatti/homekit.sh)

Setup for home automation
-------------------------

```
cd ~/.config/homekit.sh/accessories
```

Clone this repo
```
git clone https://github.com/jyrimatti/bmw.git
cd bmw
```

Store your BMW Connected Drive username/password and car VIN
```
echo '<my username>' > .bmw-user
echo '<my password>' > .bmw-pass
echo '<my VIN>' > .bmw-vin
chmod go-rwx .bmw*
```
