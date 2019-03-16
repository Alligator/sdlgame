#include <assert.h>
#include "assetloader.h"
#include "files.h"
#include "../shared.h"

#include <soloud.h>
#include <soloud_wav.h>
#include <soloud_thread.h>
#include <soloud_speech.h>
#include <soloud_openmpt.h>

extern SoLoud::Soloud soloud;

void* Speech_Load(Asset &asset) {
	auto speech = new SoLoud::Speech();
	speech->setText(asset.path);

	return (void*)speech;
}

void Speech_Free(Asset &asset) {
	SoLoud::Speech* speech = (SoLoud::Speech*) asset.resource;
	delete speech;
}

void* Sound_Load(Asset &asset) {
	unsigned char *musicbuf;
	auto sz = FS_ReadFile(asset.path, (void **)&musicbuf);

	if (sz <= 0) {
		return nullptr;
	}

	switch (asset.type) {
		case ASSET_SOUND: {
			auto sound = new SoLoud::Wav();
			sound->loadMem(musicbuf, sz, false, true);
			return (void*)sound;
		}

		case ASSET_MOD: {
			auto mod = new SoLoud::Openmpt();
			mod->loadMem(musicbuf, sz, false, true);
			return (void*)mod;
		}
	}

	return nullptr;
}

void Sound_Free(Asset &asset) {
	SoLoud::Wav* sound = (SoLoud::Wav*) asset.resource;
	delete sound;
}

void Mod_Free(Asset &asset) {
	SoLoud::Openmpt* mod = (SoLoud::Openmpt*) asset.resource;
	delete mod;
}

unsigned int Snd_Play(AssetHandle assetHandle, float volume, float pan, bool loop) {
	Asset* asset = Asset_Get(ASSET_ANY, assetHandle);

	if (asset->type != ASSET_SOUND && asset->type != ASSET_SPEECH && asset->type != ASSET_MOD) {
		Con_Error(ERR_GAME, "Snd_Play: asset not valid");
		return 0;
	}

	if (asset->resource == nullptr) {
		Con_Error(ERR_GAME, "Snd_Play: asset resource not valid");
		return 0;
	}

	SoLoud::AudioSource *src = (SoLoud::AudioSource*) asset->resource;
	src->setLooping(loop);
	return soloud.play(*src, volume, pan);
}

void Snd_Stop(unsigned int handle) {
	soloud.stop(handle);
}

void Snd_PauseResume(unsigned int handle, bool pause) {
	soloud.setPause(handle, pause);
}