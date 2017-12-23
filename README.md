p5-imap-delmail
===============

What's ?
--------
IMAPクライアントとしてログインし、その時点で取得した既読メールを全て削除する。

Redmine にて Mailbox からチケット登録を行う機能がある。
この機能は定期的に Mailbox アクセスし、

- チケット登録条件に該当するものであれば Redmine　登録のうえで Mail を削除
- 該当しないものはそのまま既読化して終了（ Mailbox には残置）

という動きをとる。
（厳密には、該当しないものの処理を別フォルダに移動するなどの機能を有しているが現在利用しているDockerコンテナではそうなっていない）

そのため、削除専用のスクリプトを定期的に実行し、Mailbox に不要メールを残さないよう対策をとる目的で作成した。

Specification
--------------
1. IMAPログインし、未読メールを全て削除する
2. 削除処理したメールタイトルの一覧をログに吐き出す `/home/app/log`

Usage
--------
コンテナを起動するだけでスクリプトが実行される。実行時には以下3つの変数を設定する必要がある。

~~~
$ cat > imap.env <<EOF
X_IMAP_REDMINE_USER=
X_IMAP_REDMINE_PASS=
X_IMAP_REDMINE_MAILHOST=
EOF
~~~

- **X_IMAP_REDMINE_USER**: IMAPアカウントユーザー名
- **X_IMAP_REDMINE_PASS**: IMAPアカウントパスワード
- **X_IMAP_REDMINE_MAILHOST**: IMAPホスト名

ログを残したい場合、ログ用ボリュームをマウントすること。

~~~
-v /path/to/vollume:/home/app/log
~~~

Cron
------------
以下利用を想定。

~~~
* * * * * docker-compose -f /path/to/docker-compose.yml up
~~~

Restriction
------------
- IMAP接続は port 993 の SSL 接続を前提としている。
