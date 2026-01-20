const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addLibrary(.{
        .name = "openmpt",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libcpp = true,
        }),
    });

    // C++ flags matching upstream Makefile
    const cxxflags: []const []const u8 = &.{
        "-fvisibility=hidden",
        "-fno-strict-aliasing",
        // This is the key define that enables libopenmpt build mode
        "-DLIBOPENMPT_BUILD",
        // Use bundled fallback implementations instead of external deps
        "-DMPT_WITH_MINIZ",
        "-DMINIZ_NO_STDIO",
        "-DMPT_WITH_MINIMP3",
        "-DMPT_WITH_STBVORBIS",
        // Disable external dependencies we don't have
        "-DNO_ZLIB",
        "-DNO_MPG123",
        "-DNO_OGG",
        "-DNO_VORBIS",
        "-DNO_VORBISFILE",
        // Include paths
        "-I",
        b.path("src").getPath(b),
        "-I",
        b.path("common").getPath(b),
        "-I",
        b.path(".").getPath(b),
        "-I",
        b.path("include").getPath(b),
    };

    // Common sources
    const common_sources: []const []const u8 = &.{
        "common/ComponentManager.cpp",
        "common/Logging.cpp",
        "common/Profiler.cpp",
        "common/mptFileType.cpp",
        "common/mptPathString.cpp",
        "common/mptRandom.cpp",
        "common/mptStringBuffer.cpp",
        "common/mptTime.cpp",
        "common/serialization_utils.cpp",
        "common/version.cpp",
    };

    // Sound DSP sources
    const sounddsp_sources: []const []const u8 = &.{
        "sounddsp/AGC.cpp",
        "sounddsp/DSP.cpp",
        "sounddsp/EQ.cpp",
        "sounddsp/Reverb.cpp",
    };

    // Soundlib sources (main module loading/playback engine)
    const soundlib_sources: []const []const u8 = &.{
        "soundlib/AudioCriticalSection.cpp",
        "soundlib/ContainerMMCMP.cpp",
        "soundlib/ContainerPP20.cpp",
        "soundlib/ContainerUMX.cpp",
        "soundlib/ContainerXPK.cpp",
        "soundlib/Dlsbank.cpp",
        "soundlib/Fastmix.cpp",
        "soundlib/ITCompression.cpp",
        "soundlib/ITTools.cpp",
        "soundlib/InstrumentExtensions.cpp",
        "soundlib/InstrumentSynth.cpp",
        "soundlib/Load_667.cpp",
        "soundlib/Load_669.cpp",
        "soundlib/Load_amf.cpp",
        "soundlib/Load_ams.cpp",
        "soundlib/Load_c67.cpp",
        "soundlib/Load_cba.cpp",
        "soundlib/Load_dbm.cpp",
        "soundlib/Load_digi.cpp",
        "soundlib/Load_dmf.cpp",
        "soundlib/Load_dsm.cpp",
        "soundlib/Load_dsym.cpp",
        "soundlib/Load_dtm.cpp",
        "soundlib/Load_etx.cpp",
        "soundlib/Load_far.cpp",
        "soundlib/Load_fc.cpp",
        "soundlib/Load_fmt.cpp",
        "soundlib/Load_ftm.cpp",
        "soundlib/Load_gdm.cpp",
        "soundlib/Load_gmc.cpp",
        "soundlib/Load_gt2.cpp",
        "soundlib/Load_ice.cpp",
        "soundlib/Load_imf.cpp",
        "soundlib/Load_ims.cpp",
        "soundlib/Load_it.cpp",
        "soundlib/Load_itp.cpp",
        "soundlib/Load_kris.cpp",
        "soundlib/Load_mdl.cpp",
        "soundlib/Load_med.cpp",
        "soundlib/Load_mid.cpp",
        "soundlib/Load_mo3.cpp",
        "soundlib/Load_mod.cpp",
        "soundlib/Load_mt2.cpp",
        "soundlib/Load_mtm.cpp",
        "soundlib/Load_mus_km.cpp",
        "soundlib/Load_okt.cpp",
        "soundlib/Load_plm.cpp",
        "soundlib/Load_psm.cpp",
        "soundlib/Load_pt36.cpp",
        "soundlib/Load_ptm.cpp",
        "soundlib/Load_puma.cpp",
        "soundlib/Load_rtm.cpp",
        "soundlib/Load_s3m.cpp",
        "soundlib/Load_sfx.cpp",
        "soundlib/Load_stk.cpp",
        "soundlib/Load_stm.cpp",
        "soundlib/Load_stp.cpp",
        "soundlib/Load_symmod.cpp",
        "soundlib/Load_tcb.cpp",
        "soundlib/Load_uax.cpp",
        "soundlib/Load_ult.cpp",
        "soundlib/Load_unic.cpp",
        "soundlib/Load_wav.cpp",
        "soundlib/Load_xm.cpp",
        "soundlib/Load_xmf.cpp",
        "soundlib/MIDIEvents.cpp",
        "soundlib/MIDIMacroParser.cpp",
        "soundlib/MIDIMacros.cpp",
        "soundlib/MODTools.cpp",
        "soundlib/MPEGFrame.cpp",
        "soundlib/Message.cpp",
        "soundlib/MixFuncTable.cpp",
        "soundlib/MixerLoops.cpp",
        "soundlib/MixerSettings.cpp",
        "soundlib/ModChannel.cpp",
        "soundlib/ModInstrument.cpp",
        "soundlib/ModSample.cpp",
        "soundlib/ModSequence.cpp",
        "soundlib/OPL.cpp",
        "soundlib/OggStream.cpp",
        "soundlib/Paula.cpp",
        "soundlib/PlayState.cpp",
        "soundlib/PlaybackTest.cpp",
        "soundlib/RowVisitor.cpp",
        "soundlib/S3MTools.cpp",
        "soundlib/SampleFormatBRR.cpp",
        "soundlib/SampleFormatFLAC.cpp",
        "soundlib/SampleFormatMP3.cpp",
        "soundlib/SampleFormatMediaFoundation.cpp",
        "soundlib/SampleFormatOpus.cpp",
        "soundlib/SampleFormatSFZ.cpp",
        "soundlib/SampleFormatVorbis.cpp",
        "soundlib/SampleFormats.cpp",
        "soundlib/SampleIO.cpp",
        "soundlib/Snd_flt.cpp",
        "soundlib/Snd_fx.cpp",
        "soundlib/Sndfile.cpp",
        "soundlib/Sndmix.cpp",
        "soundlib/SoundFilePlayConfig.cpp",
        "soundlib/Tables.cpp",
        "soundlib/Tagging.cpp",
        "soundlib/TinyFFT.cpp",
        "soundlib/UMXTools.cpp",
        "soundlib/UpgradeModule.cpp",
        "soundlib/WAVTools.cpp",
        "soundlib/WindowedFIR.cpp",
        "soundlib/XMTools.cpp",
        "soundlib/load_j2b.cpp",
        "soundlib/mod_specifications.cpp",
        "soundlib/modcommand.cpp",
        "soundlib/modsmp_ctrl.cpp",
        "soundlib/pattern.cpp",
        "soundlib/patternContainer.cpp",
        "soundlib/tuning.cpp",
        "soundlib/tuningCollection.cpp",
    };

    // Soundlib plugin sources
    const soundlib_plugin_sources: []const []const u8 = &.{
        "soundlib/plugins/DigiBoosterEcho.cpp",
        "soundlib/plugins/LFOPlugin.cpp",
        "soundlib/plugins/PlugInterface.cpp",
        "soundlib/plugins/PluginManager.cpp",
        "soundlib/plugins/SymMODEcho.cpp",
        "soundlib/plugins/dmo/Chorus.cpp",
        "soundlib/plugins/dmo/Compressor.cpp",
        "soundlib/plugins/dmo/DMOPlugin.cpp",
        "soundlib/plugins/dmo/DMOUtils.cpp",
        "soundlib/plugins/dmo/Distortion.cpp",
        "soundlib/plugins/dmo/Echo.cpp",
        "soundlib/plugins/dmo/Flanger.cpp",
        "soundlib/plugins/dmo/Gargle.cpp",
        "soundlib/plugins/dmo/I3DL2Reverb.cpp",
        "soundlib/plugins/dmo/ParamEq.cpp",
        "soundlib/plugins/dmo/WavesReverb.cpp",
    };

    // Unarchiver sources
    const unarchiver_sources: []const []const u8 = &.{
        "unarchiver/unancient.cpp",
        "unarchiver/unarchiver.cpp",
        "unarchiver/ungzip.cpp",
        "unarchiver/unlha.cpp",
        "unarchiver/unrar.cpp",
        "unarchiver/unzip.cpp",
    };

    // libopenmpt API sources (only the library API, not plugins)
    const libopenmpt_sources: []const []const u8 = &.{
        "libopenmpt/libopenmpt_c.cpp",
        "libopenmpt/libopenmpt_cxx.cpp",
        "libopenmpt/libopenmpt_ext_impl.cpp",
        "libopenmpt/libopenmpt_impl.cpp",
    };

    // Bundled fallback implementations (C files)
    const bundled_c_sources: []const []const u8 = &.{
        "include/miniz/miniz.c",
        "include/minimp3/minimp3.c",
        "include/stb_vorbis/stb_vorbis.c",
    };

    const cflags: []const []const u8 = &.{
        "-DMPT_WITH_MINIZ",
        "-DMINIZ_NO_STDIO",
        "-I",
        b.path("include").getPath(b),
    };

    // Add C++ sources
    lib.addCSourceFiles(.{
        .files = common_sources,
        .flags = cxxflags,
    });
    lib.addCSourceFiles(.{
        .files = sounddsp_sources,
        .flags = cxxflags,
    });
    lib.addCSourceFiles(.{
        .files = soundlib_sources,
        .flags = cxxflags,
    });
    lib.addCSourceFiles(.{
        .files = soundlib_plugin_sources,
        .flags = cxxflags,
    });
    lib.addCSourceFiles(.{
        .files = unarchiver_sources,
        .flags = cxxflags,
    });
    lib.addCSourceFiles(.{
        .files = libopenmpt_sources,
        .flags = cxxflags,
    });

    // Add bundled C sources
    lib.addCSourceFiles(.{
        .files = bundled_c_sources,
        .flags = cflags,
    });

    // Install public headers
    lib.installHeader(b.path("libopenmpt/libopenmpt.h"), "libopenmpt/libopenmpt.h");
    lib.installHeader(b.path("libopenmpt/libopenmpt.hpp"), "libopenmpt/libopenmpt.hpp");
    lib.installHeader(b.path("libopenmpt/libopenmpt_config.h"), "libopenmpt/libopenmpt_config.h");
    lib.installHeader(b.path("libopenmpt/libopenmpt_version.h"), "libopenmpt/libopenmpt_version.h");
    lib.installHeader(b.path("libopenmpt/libopenmpt_ext.h"), "libopenmpt/libopenmpt_ext.h");
    lib.installHeader(b.path("libopenmpt/libopenmpt_ext.hpp"), "libopenmpt/libopenmpt_ext.hpp");
    lib.installHeader(b.path("libopenmpt/libopenmpt_stream_callbacks_buffer.h"), "libopenmpt/libopenmpt_stream_callbacks_buffer.h");
    lib.installHeader(b.path("libopenmpt/libopenmpt_stream_callbacks_fd.h"), "libopenmpt/libopenmpt_stream_callbacks_fd.h");
    lib.installHeader(b.path("libopenmpt/libopenmpt_stream_callbacks_file.h"), "libopenmpt/libopenmpt_stream_callbacks_file.h");

    b.installArtifact(lib);

    // Simple test executable to verify the library works
    const test_exe = b.addExecutable(.{
        .name = "test_openmpt",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    test_exe.addCSourceFiles(.{
        .files = &.{"test_build.c"},
        .flags = &.{},
    });
    test_exe.linkLibrary(lib);

    const run_test = b.addRunArtifact(test_exe);
    const test_step = b.step("test", "Run libopenmpt build verification test");
    test_step.dependOn(&run_test.step);
}
