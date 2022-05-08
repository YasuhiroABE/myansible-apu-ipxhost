概要
===

PC Engines社製 APU/APU2にネットワーク経由(iPXE)でUbuntu 22.04を自動インストール(AutoInstall)するiPXEホストを構成するために必要な設定をまとめたプロジェクトファイルです。

makeコマンドとAnsibleにより、APUをiPXEホストとして構成します。

詳細はQiitaに作成した文書を参照してください。

使い方
=====

あらかじめiPXEホストとなるAPUにUbuntu 22.04が導入され、ネットワークに接続されている事が前提です。

準備作業
--------

プロジェクトをgit cloneし、ansibleコマンドが実行できるように ansible.cfg ファイルを設定します。

    $ git clone https://github.com/YasuhiroABE/myansible-apu-ipxhost.git
	$ cd myansible-apu-ipxhost
	
	## remote_user を修正します。
	$ vi ansible.cfg
	
	## iPXEホストとなるAPUのIPアドレスに修正します
	$ vi hosts
	
makeコマンドの実行
-----------------

最初に必要なファイル・ディレクトリを構成します

    $ make role-init
	$ make setup-filedir
	$ make setup-dnsmasq
	$ make setup-nginx

設定を反映させるために、iPXEホストとなるAPUを再起動します

    $ ansible all -m command -b -a "shutdown -r now"
	
Ansible Playbookにより残りの設定を反映します

    $ make
