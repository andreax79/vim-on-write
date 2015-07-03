# vim-on-write
Easily register commands executed when the current buffer or a given files matching a glob are saved

**USAGE**

**:OnWrite < command >**

    Register a command executed when the current buffer is saved.
    Only one command can be registered for a buffer.

*Example:*

    The following comman copy the current file on the server when the buffer
    is written.
    :OnWrite scp % server:/tmp/

**:OnWriteGlob < glob > < command >**

    Register a command executed when a file matching the glob is saved.
    Only one command can be registered for a glob, but a single file can
    match multiple glob.

*Example:*

    The following command copy the *.py files when are saved.
    :OnWriteGlob *.py scp % server:/tmp/

**:CancelOnWrite [< glob >]**

    Remove the command triggered for the current buffer or a glob.
