---
layout: post
title: Repo Usage
categories: Android
description: repo history, creation and usage
keywords: repo, git, python
topmost: true
---



### Basic Introduction

![img](../images/posts/android/20140114004627265)



- Repo脚本

- Repo仓库

- Manifest仓库
- AOSP子项目仓库



主要是Linux版本

Windows版本可查看：

```markdown
repo/docs/windows.md

# References：
* https://github.com/git-for-windows/git/wiki/Symbolic-Links
* https://blogs.windows.com/windowsdeveloper/2016/12/02/symlinks-windows-10/

```

不太建议使用。



Google official：

```markdown
create bin
    mkdir ~/bin
    PATH=~/bin:$PATH

repo bin
    curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
    sudo chmod a+x ~/bin/repo

repo init -u https://android.googlesource.com/platform/manifest
```



如果Repo脚本所在的目录存在一个Repo仓库，那么要满足以下条件：

​    (1). 存在一个.git目录；

​    (2). 存在一个main.py文件；

​    (3). 存在一个git_config.py文件；

​    (4). 存在一个project.py文件；

​    (5). 存在一个subcmds目录。



```shell
.repo$ tree -L 1
.
├── copy-link-files.json
├── internal-fs-layout.md -> repo/docs/internal-fs-layout.md
├── manifests
├── manifests.git
├── manifest.xml
├── project.list
├── project-objects
├── projects
├── repo
└── TRACE_FILE

.repo/repo$ tree -d -L 1
.
├── docs
├── hooks
├── man
├── __pycache__
├── release
├── subcmds
└── tests

```



XmlManifest作了描述了AOSP的Repo目录（repodir）、AOSP 根目录（topdir）和Manifest.xml文件（manifestFile）之外，

还使用两个MetaProject对象描述了AOSP的Repo仓库（repoProject）和Manifest仓库（manifestProject）。



.repo/repo/project.py



### Creation of REPO

```markdown
REPO_URL = 'https://blqsrv819.dl.net/android-common-utils/git-repo.git'
REPO_REV = 'stable'

repo --trace init -u manifest_git_path -m manifest_file_name -b branch_name --repo-url=repo_url --no-repo-verify

-u: 指定Manifest库的Git访问路径。
-m: 指定要使用的Manifest文件。
-b: 指定要使用Manifest仓库中的某个特定分支。
–repo-url: 指定要检查repo是否有更新的远端repoGit库的访问路径。
–no-repo-verify: 指定不检查repo库是否需要更新。
```



DL源  (repo 版本较老)：

```shell
repo --trace init -u git@blqsrv819.dl.net:repo_test/manifest.git -b dl36_r_dev  -m default.xml --repo-url=git@blqsrv819.dl.net:android-common-utils/git-repo.git --no-repo-verify
```



国内源 (repo 新版本)：

```
repo --trace init -u git@blqsrv819.dl.net:repo_test/trainning_manifest.git -b main   --repo-url=https://gerrit-googlesource.lug.ustc.edu.cn/git-repo --no-repo-verify
```



自行创建实验：

```
repo --trace init -u git@blqsrv819.dl.net:repo_test/trainning_manifest.git -b main   --repo-url=git@blqsrv819.dl.net:android-common-utils/git-repo.git --no-repo-verify
```





参考.repo/repo/docs/manifest-format.txt文件

````markdown
# repo Manifest Format

A repo manifest describes the structure of a repo client; that is
the directories that are visible and where they should be obtained
from with git.

The basic structure of a manifest is a bare Git repository holding
a single `default.xml` XML file in the top level directory.

Manifests are inherently version controlled, since they are kept
within a Git repository.  Updates to manifests are automatically
obtained by clients during `repo sync`.

[TOC]


## XML File Format

A manifest XML file (e.g. `default.xml`) roughly conforms to the
following DTD:

​```xml
<!DOCTYPE manifest [
  <!ELEMENT manifest (notice?,
                      remote*,
                      default?,
                      manifest-server?,
                      remove-project*,
                      project*,
                      extend-project*,
                      repo-hooks?,
                      include*)>

  <!ELEMENT notice (#PCDATA)>

  <!ELEMENT remote EMPTY>
  <!ATTLIST remote name         ID    #REQUIRED>
  <!ATTLIST remote alias        CDATA #IMPLIED>
  <!ATTLIST remote fetch        CDATA #REQUIRED>
  <!ATTLIST remote pushurl      CDATA #IMPLIED>
  <!ATTLIST remote review       CDATA #IMPLIED>
  <!ATTLIST remote revision     CDATA #IMPLIED>

  <!ELEMENT default EMPTY>
  <!ATTLIST default remote      IDREF #IMPLIED>
  <!ATTLIST default revision    CDATA #IMPLIED>
  <!ATTLIST default dest-branch CDATA #IMPLIED>
  <!ATTLIST default upstream    CDATA #IMPLIED>
  <!ATTLIST default sync-j      CDATA #IMPLIED>
  <!ATTLIST default sync-c      CDATA #IMPLIED>
  <!ATTLIST default sync-s      CDATA #IMPLIED>
  <!ATTLIST default sync-tags   CDATA #IMPLIED>

  <!ELEMENT manifest-server EMPTY>
  <!ATTLIST manifest-server url CDATA #REQUIRED>

  <!ELEMENT project (annotation*,
                     project*,
                     copyfile*,
                     linkfile*)>
  <!ATTLIST project name        CDATA #REQUIRED>
  <!ATTLIST project path        CDATA #IMPLIED>
  <!ATTLIST project remote      IDREF #IMPLIED>
  <!ATTLIST project revision    CDATA #IMPLIED>
  <!ATTLIST project dest-branch CDATA #IMPLIED>
  <!ATTLIST project groups      CDATA #IMPLIED>
  <!ATTLIST project sync-c      CDATA #IMPLIED>
  <!ATTLIST project sync-s      CDATA #IMPLIED>
  <!ATTLIST project sync-tags   CDATA #IMPLIED>
  <!ATTLIST project upstream CDATA #IMPLIED>
  <!ATTLIST project clone-depth CDATA #IMPLIED>
  <!ATTLIST project force-path CDATA #IMPLIED>

  <!ELEMENT annotation EMPTY>
  <!ATTLIST annotation name  CDATA #REQUIRED>
  <!ATTLIST annotation value CDATA #REQUIRED>
  <!ATTLIST annotation keep  CDATA "true">

  <!ELEMENT copyfile EMPTY>
  <!ATTLIST copyfile src  CDATA #REQUIRED>
  <!ATTLIST copyfile dest CDATA #REQUIRED>

  <!ELEMENT linkfile EMPTY>
  <!ATTLIST linkfile src CDATA #REQUIRED>
  <!ATTLIST linkfile dest CDATA #REQUIRED>

  <!ELEMENT extend-project EMPTY>
  <!ATTLIST extend-project name CDATA #REQUIRED>
  <!ATTLIST extend-project path CDATA #IMPLIED>
  <!ATTLIST extend-project groups CDATA #IMPLIED>
  <!ATTLIST extend-project revision CDATA #IMPLIED>

  <!ELEMENT remove-project EMPTY>
  <!ATTLIST remove-project name  CDATA #REQUIRED>

  <!ELEMENT repo-hooks EMPTY>
  <!ATTLIST repo-hooks in-project CDATA #REQUIRED>
  <!ATTLIST repo-hooks enabled-list CDATA #REQUIRED>

  <!ELEMENT include EMPTY>
  <!ATTLIST include name CDATA #REQUIRED>
]>

A description of the elements and their attributes follows.


### Element manifest

The root element of the file.


### Element remote

One or more remote elements may be specified.  Each remote element
specifies a Git URL shared by one or more projects and (optionally)
the Gerrit review server those projects upload changes through.

Attribute `name`: A short name unique to this manifest file.  The
name specified here is used as the remote name in each project's
.git/config, and is therefore automatically available to commands
like `git fetch`, `git remote`, `git pull` and `git push`.

Attribute `alias`: The alias, if specified, is used to override
`name` to be set as the remote name in each project's .git/config.
Its value can be duplicated while attribute `name` has to be unique
in the manifest file. This helps each project to be able to have
same remote name which actually points to different remote url.

Attribute `fetch`: The Git URL prefix for all projects which use
this remote.  Each project's name is appended to this prefix to
form the actual URL used to clone the project.

Attribute `pushurl`: The Git "push" URL prefix for all projects
which use this remote.  Each project's name is appended to this
prefix to form the actual URL used to "git push" the project.
This attribute is optional; if not specified then "git push"
will use the same URL as the `fetch` attribute.

Attribute `review`: Hostname of the Gerrit server where reviews
are uploaded to by `repo upload`.  This attribute is optional;
if not specified then `repo upload` will not function.

Attribute `revision`: Name of a Git branch (e.g. `master` or
`refs/heads/master`). Remotes with their own revision will override
the default revision.

### Element default

At most one default element may be specified.  Its remote and
revision attributes are used when a project element does not
specify its own remote or revision attribute.

Attribute `remote`: Name of a previously defined remote element.
Project elements lacking a remote attribute of their own will use
this remote.

Attribute `revision`: Name of a Git branch (e.g. `master` or
`refs/heads/master`).  Project elements lacking their own
revision attribute will use this revision.

Attribute `dest-branch`: Name of a Git branch (e.g. `master`).
Project elements not setting their own `dest-branch` will inherit
this value. If this value is not set, projects will use `revision`
by default instead.

Attribute `upstream`: Name of the Git ref in which a sha1
can be found.  Used when syncing a revision locked manifest in
-c mode to avoid having to sync the entire ref space. Project elements
not setting their own `upstream` will inherit this value.

Attribute `sync-j`: Number of parallel jobs to use when synching.

Attribute `sync-c`: Set to true to only sync the given Git
branch (specified in the `revision` attribute) rather than the
whole ref space.  Project elements lacking a sync-c element of
their own will use this value.

Attribute `sync-s`: Set to true to also sync sub-projects.

Attribute `sync-tags`: Set to false to only sync the given Git
branch (specified in the `revision` attribute) rather than
the other ref tags.


### Element manifest-server

At most one manifest-server may be specified. The url attribute
is used to specify the URL of a manifest server, which is an
XML RPC service.

The manifest server should implement the following RPC methods:

    GetApprovedManifest(branch, target)

Return a manifest in which each project is pegged to a known good revision
for the current branch and target. This is used by repo sync when the
--smart-sync option is given.

The target to use is defined by environment variables TARGET_PRODUCT
and TARGET_BUILD_VARIANT. These variables are used to create a string
of the form $TARGET_PRODUCT-$TARGET_BUILD_VARIANT, e.g. passion-userdebug.
If one of those variables or both are not present, the program will call
GetApprovedManifest without the target parameter and the manifest server
should choose a reasonable default target.

    GetManifest(tag)

Return a manifest in which each project is pegged to the revision at
the specified tag. This is used by repo sync when the --smart-tag option
is given.


### Element project

One or more project elements may be specified.  Each element
describes a single Git repository to be cloned into the repo
client workspace.  You may specify Git-submodules by creating a
nested project.  Git-submodules will be automatically
recognized and inherit their parent's attributes, but those
may be overridden by an explicitly specified project element.

Attribute `name`: A unique name for this project.  The project's
name is appended onto its remote's fetch URL to generate the actual
URL to configure the Git remote with.  The URL gets formed as:

    ${remote_fetch}/${project_name}.git

where ${remote_fetch} is the remote's fetch attribute and
${project_name} is the project's name attribute.  The suffix ".git"
is always appended as repo assumes the upstream is a forest of
bare Git repositories.  If the project has a parent element, its
name will be prefixed by the parent's.

The project name must match the name Gerrit knows, if Gerrit is
being used for code reviews.

Attribute `path`: An optional path relative to the top directory
of the repo client where the Git working directory for this project
should be placed.  If not supplied the project name is used.
If the project has a parent element, its path will be prefixed
by the parent's.

Attribute `remote`: Name of a previously defined remote element.
If not supplied the remote given by the default element is used.

Attribute `revision`: Name of the Git branch the manifest wants
to track for this project.  Names can be relative to refs/heads
(e.g. just "master") or absolute (e.g. "refs/heads/master").
Tags and/or explicit SHA-1s should work in theory, but have not
been extensively tested.  If not supplied the revision given by
the remote element is used if applicable, else the default
element is used.

Attribute `dest-branch`: Name of a Git branch (e.g. `master`).
When using `repo upload`, changes will be submitted for code
review on this branch. If unspecified both here and in the
default element, `revision` is used instead.

Attribute `groups`: List of groups to which this project belongs,
whitespace or comma separated.  All projects belong to the group
"all", and each project automatically belongs to a group of
its name:`name` and path:`path`.  E.g. for
<project name="monkeys" path="barrel-of"/>, that project
definition is implicitly in the following manifest groups:
default, name:monkeys, and path:barrel-of.  If you place a project in the
group "notdefault", it will not be automatically downloaded by repo.
If the project has a parent element, the `name` and `path` here
are the prefixed ones.

Attribute `sync-c`: Set to true to only sync the given Git
branch (specified in the `revision` attribute) rather than the
whole ref space.

Attribute `sync-s`: Set to true to also sync sub-projects.

Attribute `upstream`: Name of the Git ref in which a sha1
can be found.  Used when syncing a revision locked manifest in
-c mode to avoid having to sync the entire ref space.

Attribute `clone-depth`: Set the depth to use when fetching this
project.  If specified, this value will override any value given
to repo init with the --depth option on the command line.

Attribute `force-path`: Set to true to force this project to create the
local mirror repository according to its `path` attribute (if supplied)
rather than the `name` attribute.  This attribute only applies to the
local mirrors syncing, it will be ignored when syncing the projects in a
client working directory.

### Element extend-project

Modify the attributes of the named project.

This element is mostly useful in a local manifest file, to modify the
attributes of an existing project without completely replacing the
existing project definition.  This makes the local manifest more robust
against changes to the original manifest.

Attribute `path`: If specified, limit the change to projects checked out
at the specified path, rather than all projects with the given name.

Attribute `groups`: List of additional groups to which this project
belongs.  Same syntax as the corresponding element of `project`.

Attribute `revision`: If specified, overrides the revision of the original
project.  Same syntax as the corresponding element of `project`.

### Element annotation

Zero or more annotation elements may be specified as children of a
project element. Each element describes a name-value pair that will be
exported into each project's environment during a 'forall' command,
prefixed with REPO__.  In addition, there is an optional attribute
"keep" which accepts the case insensitive values "true" (default) or
"false".  This attribute determines whether or not the annotation will
be kept when exported with the manifest subcommand.

### Element copyfile

Zero or more copyfile elements may be specified as children of a
project element. Each element describes a src-dest pair of files;
the "src" file will be copied to the "dest" place during `repo sync`
command.
"src" is project relative, "dest" is relative to the top of the tree.

### Element linkfile

It's just like copyfile and runs at the same time as copyfile but
instead of copying it creates a symlink.

### Element remove-project

Deletes the named project from the internal manifest table, possibly
allowing a subsequent project element in the same manifest file to
replace the project with a different source.

This element is mostly useful in a local manifest file, where
the user can remove a project, and possibly replace it with their
own definition.

### Element include

This element provides the capability of including another manifest
file into the originating manifest.  Normal rules apply for the
target manifest to include - it must be a usable manifest on its own.

Attribute `name`: the manifest to include, specified relative to
the manifest repository's root.


## Local Manifests

Additional remotes and projects may be added through local manifest
files stored in `$TOP_DIR/.repo/local_manifests/*.xml`.

For example:

    $ ls .repo/local_manifests
    local_manifest.xml
    another_local_manifest.xml
    
    $ cat .repo/local_manifests/local_manifest.xml
    <?xml version="1.0" encoding="UTF-8"?>
    <manifest>
      <project path="manifest"
               name="tools/manifest" />
      <project path="platform-manifest"
               name="platform/manifest" />
    </manifest>

Users may add projects to the local manifest(s) prior to a `repo sync`
invocation, instructing repo to automatically download and manage
these extra projects.

Manifest files stored in `$TOP_DIR/.repo/local_manifests/*.xml` will
be loaded in alphabetical order.

Additional remotes and projects may also be added through a local
manifest, stored in `$TOP_DIR/.repo/local_manifest.xml`. This method
is deprecated in favor of using multiple manifest files as mentioned
above.

If `$TOP_DIR/.repo/local_manifest.xml` exists, it will be loaded before
any manifest files stored in `$TOP_DIR/.repo/local_manifests/*.xml`.
```



元素中文含义

````markdown
Manifest解析

## Element manifest
manifest：文件的根元素。

## Element notice
完成时向用户显示的任意文本repo sync。内容只是通过它存在于清单中。

## Element remote
属性name：此清单文件唯一的短名称。此处指定的名称用作每个项目的 .git/config 中的远程名称，因此自动可用于git fetch、git remote和git pull等命令git push。
属性alias：别名（如果指定）用于覆盖name以在每个项目的 .git/config 中设置为远程名称。它的值可以重复，而属性name在清单文件中必须是唯一的。这有助于每个项目能够具有相同的远程名称，该名称实际上指向不同的远程 url。
属性fetch：使用此远程的所有项目的 Git URL 前缀。每个项目的名称都附加到此前缀以形成用于克隆项目的实际 URL。
属性pushurl：使用此远程的所有项目的 Git“推送”URL 前缀。每个项目的名称都附加到此前缀，以形成用于“git push”项目的实际 URL。这个属性是可选的；如果未指定，则“git push”将使用与属性相同的 URL fetch。
属性review：上传到的 Gerrit 服务器的主机名repo upload。这个属性是可选的；如果未指定，repo upload则将不起作用。
属性revision：Git 分支的名称（例如main或refs/heads/main）。具有自己版本的遥控器将覆盖默认版本。

## Element default
属性remote：先前定义的远程元素的名称。缺少自己的远程属性的项目元素将使用此远程。
属性revision：Git 分支的名称（例如main或refs/heads/main）。缺少自己的修订属性的项目元素将使用此修订。
属性dest-branch：Git 分支的名称（例如main）。未设置自己的项目元素dest-branch将继承此值。如果未设置此值，项目将revision默认使用。
属性upstream：可以在其中找到 sha1 的 Git 引用的名称。在 -c 模式下同步修订锁定清单时使用，以避免必须同步整个引用空间。未设置自己的项目元素upstream将继承此值。
属性sync-j：同步时要使用的并行作业数。
属性sync-c：设置为 true 以仅同步给定的 Git 分支（在revision属性中指定）而不是整个引用空间。缺少自己的 sync-c 元素的项目元素将使用此值。
属性sync-s：设置为 true 也同步子项目。
属性sync-tags：设置为 false 以仅同步给定的 Git 分支（在属性中指定revision）而不是其他 ref 标记。

## Element manifest-server
最多可以指定一个清单服务器。url 属性用于指定清单服务器的 URL，它是一个 XML RPC 服务。

清单服务器应实现以下 RPC 方法：
GetApprovedManifest(branch, target)
返回一个清单，其中每个项目都与当前分支和目标的已知良好修订挂钩。当给出 --smart-sync 选项时，repo sync 使用它。
要使用的目标由环境变量 TARGET_PRODUCT 和 TARGET_BUILD_VARIANT 定义。这些变量用于创建 $TARGET_PRODUCT-$TARGET_BUILD_VARIANT 形式的字符串，例如 passion-userdebug。如果这些变量之一或两者都不存在，程序将调用不带目标参数的 GetApprovedManifest，清单服务器应选择一个合理的默认目标。
GetManifest(tag)
返回一个清单，其中每个项目都与指定标记处的修订挂钩。当给出 --smart-tag 选项时，repo sync 使用它。

## Element submanifest
属性name：此子清单的唯一名称（在当前（子）清单中）。它作为revision下面的默认值。相同的名称可用于具有不同父（子）清单的子清单。
属性remote：先前定义的远程元素的名称。如果未提供，则使用默认元素给出的远程。
属性project：清单项目名称。项目的名称附加到其远程的获取 URL 以生成实际的 URL 来配置 Git 远程。URL 的格式如下：
${remote_fetch}/${project_name}.git
其中 ${remote_fetch} 是远程的 fetch 属性，${project_name} 是项目的名称属性。总是附加后缀“.git”，因为 repo 假定上游是一个裸 Git 存储库的森林。如果项目有父元素，其名称将以父元素为前缀。
如果 Gerrit 用于代码审查，项目名称必须与 Gerrit 知道的名称相匹配。
project不能为空，不能是绝对路径或使用“.” 或“..”路径组件。它总是相对于遥控器的获取设置进行解释，因此如果需要不同的基本路径，请使用所需的新设置声明一个不同的遥控器。
如果未提供，将使用此清单的远程和项目：remote无法提供。
来自子清单的项目及其子清单被添加到 submanifest::path:<path_prefix> 组。
属性manifest-name：清单项目中的清单文件名。如果未提供，default.xml则使用。
属性revision：Git 分支的名称（例如“main”或“refs/heads/main”）、标签（例如“refs/tags/stable”）或提交哈希。如果未提供，name则使用。
属性path：相对于 repo 客户端顶级目录的可选路径，子清单 repo 客户端顶级目录应放置在该目录中。如果未提供，revision则使用。path可能不是绝对路径或使用“.” 或“..”路径组件。
属性groups：包含的子清单中的所有项目所属的附加组的列表。这会追加和递归，这意味着子清单中的所有项目都带有所有父子清单组。与 的相应元素相同的语法project。
属性default-groups：如果在初始化时未指定参数，则要同步的清单组列表--groups=。当该列表为空时，使用此列表而不是“默认”作为要同步的组列表。

## Element project
可以指定一个或多个项目元素。每个元素都描述了一个要克隆到 repo 客户端工作区中的 Git 存储库。您可以通过创建嵌套项目来指定 Git-submodules。Git 子模块将被自动识别并继承其父模块的属性，但这些模块可能会被明确指定的项目元素覆盖。

属性name：此项目的唯一名称。项目的名称附加到其远程的获取 URL 以生成实际的 URL 来配置 Git 远程。URL 的格式如下：
${remote_fetch}/${project_name}.git
其中 ${remote_fetch} 是远程的 fetch 属性，${project_name} 是项目的名称属性。总是附加后缀“.git”，因为 repo 假定上游是一个裸 Git 存储库的森林。如果项目有父元素，其名称将以父元素为前缀。
如果 Gerrit 用于代码审查，项目名称必须与 Gerrit 知道的名称相匹配。“名称”不能为空，也不能是绝对路径或使用“.”。或“..”路径组件。它总是相对于遥控器的获取设置进行解释，因此如果需要不同的基本路径，请使用所需的新设置声明一个不同的遥控器。不对Local Manifests强制执行这些限制。
属性path：相对于 repo 客户端顶层目录的可选路径，该项目的 Git 工作目录应放置在该目录中。如果未提供，则使用项目“名称”。如果项目有父元素，其路径将以父元素为前缀。“路径”可能不是绝对路径或使用“.” 或“..”路径组件。不对Local Manifests强制执行这些限制。
如果您想将文件放入结帐的根目录（例如 README 或 Makefile 或其他构建脚本），请改用 copyfile或linkfile元素。
属性remote：先前定义的远程元素的名称。如果未提供，则使用默认元素给出的远程。
属性revision：清单要为此项目跟踪的 Git 分支的名称。名称可以相对于 refs/heads（例如“main”）或绝对的（例如“refs/heads/main”）。标签和/或显式 SHA-1 在理论上应该有效，但尚未经过广泛测试。如果未提供，则使用远程元素给出的修订版（如果适用），否则使用默认元素。
属性dest-branch：Git 分支的名称（例如main）。使用时repo upload，更改将提交到该分支进行代码审查。如果在此处和默认元素中均未指定，revision则使用。
属性groups：该项目所属的组列表，以空格或逗号分隔。所有项目都属于“all”组，每个项目自动属于一组名称：name和路径：path。例如<project name="monkeys" path="barrel-of"/>，该项目定义隐含在以下清单组中：default、name:monkeys 和 path:barrel-of。如果你将一个项目放在“notdefault”组中，它不会被 repo 自动下载。如果项目有父元素，则name和path此处是前缀元素。
属性sync-c：设置为 true 以仅同步给定的 Git 分支（在revision属性中指定）而不是整个引用空间。
属性sync-s：设置为 true 也同步子项目。
属性upstream：可以在其中找到 sha1 的 Git 引用的名称。在 -c 模式下同步修订锁定清单时使用，以避免必须同步整个引用空间。
属性clone-depth：设置获取此项目时要使用的深度。如果指定，此值将覆盖在命令行上使用 --depth 选项提供给 repo init 的任何值。
属性force-path：设置为 true 以强制此项目根据其path属性（如果提供）而不是name属性创建本地镜像存储库。此属性仅适用于本地镜像同步，在客户端工作目录中同步项目时将被忽略。

## Element extend-project
修改命名项目的属性。 此元素在本地清单文件中最有用，可在不完全替换现有项目定义的情况下修改现有项目的属性。这使得本地清单对原始清单的更改更加健壮。

属性path：如果指定，则将更改限制为在指定路径签出的项目，而不是具有给定名称的所有项目。
属性dest-path：如果指定，则为相对于 repo 客户端顶层目录的路径，该目录应放置此项目的 Git 工作目录。这用于通过覆盖现有path设置来移动结帐中的项目。
属性groups：此项目所属的其他组的列表。与 的相应元素相同的语法project。
属性revision：如果指定，将覆盖原始项目的修订版。与 的相应元素相同的语法project。
属性remote：如果指定，则覆盖原始项目的远程。与 的相应元素相同的语法project。
属性dest-branch：如果指定，将覆盖原始项目的目标分支。与 的相应元素相同的语法project。
属性upstream：如果指定，则覆盖原始项目的上游。与 的相应元素相同的语法project。

## Element annotation
可以将零个或多个注释元素指定为项目或远程元素的子元素。每个元素描述一个名称-值对。对于项目，此名称-值对将在“forall”命令期间导出到每个项目的环境中，前缀为REPO__

此外，还有一个可选属性“keep”，它接受不区分大小写的值“true”（默认）或“false”。此属性确定在使用 manifest 子命令导出时是否保留注释。
Element copyfile
可以将零个或多个 copyfile 元素指定为项目元素的子元素。每个元素描述一对 src-dest 文件；“src”文件将在repo sync命令期间被复制到“dest”位置。
“src”是相对于项目的，“dest”是相对于树的顶部的。不允许从项目外部的路径复制或复制到 repo 客户端外部的路径。
“src”和“dest”必须是文件。目录或符号链接是不允许的。中间路径也不能是符号链接。
如果缺少，将自动创建“dest”的父目录。
Element linkfile
它就像 copyfile 一样，与 copyfile 同时运行，但它不是复制而是创建一个符号链接。
符号链接在“dest”（相对于树的顶部）创建，并指向“src”指定的路径，这是项目中的路径。
如果缺少，将自动创建“dest”的父目录。
符号链接目标可以是文件或目录，但它不能指向 repo 客户端之外。

## Element remove-project
从内部清单表中删除命名项目，可能允许同一清单文件中的后续项目元素用不同的源替换项目。
此元素在本地清单文件中最有用，用户可以在其中删除项目，并可能用自己的定义替换它。
属性optional：设置为 true 以忽略没有匹配project元素的 remove-project 元素。

## Element repo-hooks
一次只能指定一个 repo-hooks 元素。

属性in-project：定义repo-hooks 的项目。该值必须与先前定义的元素的name属性（而不是属性path）相匹配project。
属性enabled-list：要使用的repo-hooks 列表，以空格或逗号分隔。
Element superproject
属性name：超级项目的唯一名称。该属性与项目的名称属性含义相同。
属性remote：先前定义的远程元素的名称。如果未提供，则使用默认元素给出的远程。
属性revision：清单要为此超级项目跟踪的 Git 分支的名称。如果未提供，则使用远程元素给出的修订版（如果适用），否则使用默认元素。

## Element contactinfo
此元素用于让清单作者自行注册联系信息。它具有“bugurl”作为必需的属性。这个元素可以重复，任何后面的条目都会破坏前面的条目。这将允许扩展清单的清单作者指定他们自己的联系信息。

属性bugurl：针对清单所有者提交错误的 URL。
Element include
此元素提供将另一个清单文件包含到原始清单中的功能。正常规则适用于要包含的目标清单 - 它必须是一个可用的清单。

属性name：要包含的清单，相对于清单存储库的根指定。“名称”可以不是绝对路径或使用“.” 或“..”路径组件。不对Local Manifests强制执行这些限制。
属性groups：包含的清单中的所有项目所属的附加组的列表。这会追加和递归，这意味着包含清单中的所有项目都带有所有父包含组。与 的相应元素相同的语法project。

官方文档：
https://github.com/GerritCodeReview/git-repo/blob/main/docs/manifest-format.md

```



#### Example:

default.xml 

```xml

<manifest>
	
	<remote 
	name="sub_projects" 
	fetch="ssh://git@blqsrv819.dl.net/repo_test"
	/>
	
	<!--<default remote="sub_projects" revision="main" sync-j="8"/>-->
	
	<project name="GitA" path="hello_world/A" revision="main" remote="sub_projects"/>
	
	<project name="GitB" path="hello_world/B" revision="main" remote="sub_projects">
		<annotation name="KEY" value="1.2.3"/>
		<!--repo forall -c 'echo $REPO__KEY'-->
		<copyfile src="README.md" dest="README.md" />
		<linkfile src="README.md" dest="README.md.link" />
	</project>
	
       <!--<include name="delete_projects.xml"/>-->
       
	
	

</manifest>

```

delete_projects.xml 

```xml

<manifest>
	<remove-project name="GitA" />
</manifest>
```

local_manifests$ cat c.xml 

```xml
<manifest>
	
	<remote 
	name="sub_projects" 
	fetch="ssh://git@blqsrv819.dl.net/repo_test"
	/>	
	
	<project name="GitC" path="hello_world/C" revision="main" remote="sub_projects">
	</project>
	<extend-project name="GitA" revision="dl36_r_smr" upstream="dl36_r_smr"/>
	
</manifest>

```



### Usage of REPO

```
repo <COMMAND> <OPTIONS>
```



```
repo version
-h, –help 显示这个帮助信息后退出.
```



```
repo selfupdate
–no-repo-verify 不要验证repo源码.
```



```
repo help [--all|command]
```



```markdown
repo sync [project_name]

-u: 指定Manifest库的Git访问路径。
-m: 指定要使用的Manifest文件。
-b: 指定要使用Manifest仓库中的某个特定分支。
–repo-url: 指定要检查repo是否有更新的远端repoGit库的访问路径。
–no-repo-verify: 指定不检查repo库是否需要更新。
```



```
repo start <newbranchname> [--all|<project>...]

```



```
repo checkout <branchname> [<project>...]
相当于 git checkout
```



```
repo branches [<project>...]

```



```
repo diff [<project>...]

```



```
repo stage -i [<project>...]
对git add –interactive命令的封装
```



```
repo prune [<project>...]
对git branch -d 命令的封装
```



```
repo abandon <branchname> [<rpoject>...]
对git brance -D命令的封装
```



```
repo status [<project>...]

```



```
repo remote add <remotename> <url> [<project>...]
repo remote rm <remotename> [<project>...]
repo push <remotename> [--all|<project>...]

repo upload [--re --cc] {[<project>]...|--replace <project>}
repo download {project change[/patchset]}
```



```
repo forall [<project>...] -c <command>

-c 后面所带的参数是shell指令，即执行命令和参数。命令是通过 /bin/sh 评估的并且后面的任何参数就如 shell 位置的参数通过。
-p 在shell指令输出之前列出项目名称，即在指定命令的输出前显示项目标题。这是通过绑定管道到命令的stdin，stdout，和 sterr 流，并且用管道输送所有输出量到一个连续的流，显示在一个单一的页面调度会话中。
-v 列出执行shell指令输出的错误信息，即显示命令写到 sterr 的信息。

```



```
repo forall -c "printenv"

REPO_PROJECT 指定项目的名称
REPO_PATH 指定项目在工作区的相对路径
REPO_REMOTE 指定项目远程仓库的名称
REPO_LREV 指定项目最后一次提交服务器仓库对应的哈希值
REPO_RREV 指定项目在克隆时的指定分支，manifest里的revision属性
```



```
repo grep {pattern | -e pattern} [<project>...]

repo grep -e '2' --and -e 'ab'

#要找一行, 里面有#define, 并且有'MAX_PATH' 或者 'PATH_MAX':
repo grep -e '#define' --and -\( -e MAX_PATH -e PATH_MAX \)

#查找一行, 里面有 'NODE'或'Unexpected', 并且在一个文件中这两个都有的.
repo grep --all-match -e NODE -e Unexpected


```



```
repo manifest [-o {-|NAME.xml} [-r]]

-h, –help 显示这个帮助信息后退出
-r, –revision-as-HEAD 把某版次存为当前的HEAD
-o -|NAME.xml, –output-file=-|NAME.xml 把manifest存为NAME.xml

```



### Use Case









