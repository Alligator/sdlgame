#include <physfs.h>
#include "console/console.h"
#include "local.h"

void Cmd_Dir_f() {
	const char *path = Cmd_Argc() > 1 ? Cmd_Argv(1) : "/";
	char **rc = PHYSFS_enumerateFiles(path);
	char **i;

	Com_Printf("Directory listing of %s\n", path);
	for (i = rc; *i != NULL; i++)
		Com_Printf("%s\n", *i);

	PHYSFS_freeList(rc);
}

bool FS_Exists(const char *file) {
	return PHYSFS_exists(file);
}

void FS_Init(const char *argv0) {
	PHYSFS_init(argv0);
	auto fs_basepath = Cvar_Get("fs_basepath", PHYSFS_getBaseDir(), CVAR_INIT);

	PHYSFS_mount(va("%s/base", fs_basepath->string), "/", 1);

	const char *archiveExt = "pk3";
	char **rc = PHYSFS_enumerateFiles("/");
	char **i;
	size_t extlen = strlen(archiveExt);
	char *ext;

	for (i = rc; *i != NULL; i++) {
		size_t l = strlen(*i);
		if ((l > extlen) && ((*i)[l - extlen - 1] == '.')) {
			ext = (*i) + (l - extlen);
			if (strcasecmp(ext, archiveExt) == 0) {
				PHYSFS_mount(va("%s/base/%s", fs_basepath->string, *i), "/", 0);
			}
		}
	}

	PHYSFS_freeList(rc);

	Cmd_AddCommand("dir", Cmd_Dir_f);
}

int FS_ReadFile(const char *path, void **buffer) {
	auto f = PHYSFS_openRead(path);

	if (f == nullptr) {
		return -1;
	}

	auto sz = PHYSFS_fileLength(f);

	if (buffer == nullptr) {
		return sz;
	}
	
	*buffer = malloc(sz);

	int read_sz = PHYSFS_read(f, *buffer, 1, sz);

	if (read_sz == -1) {
		Com_Printf("FS err: %s", PHYSFS_getLastError());
	}

	PHYSFS_close(f);

	return read_sz;
}