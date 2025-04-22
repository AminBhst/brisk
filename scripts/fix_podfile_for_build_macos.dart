import 'dart:io';

void main(List<String> arguments) async {
  if (arguments.length != 1) {
    print('Usage: dart fix_podfile_for_build_macos.dart <path_to_podfile>');
    exit(1);
  }

  final podfilePath = arguments[0];
  final podfile = File(podfilePath);
  final tempPodfilePath = '$podfilePath.tmp';
  final tempPodfile = File(tempPodfilePath);

  if (!await podfile.exists()) {
    print('Error: Podfile not found at $podfilePath');
    exit(1);
  }

  print('Processing Podfile: $podfilePath to remove RunnerTests target...');

  bool inTargetBlock = false;
  int nestLevel = 0;
  int linesSkipped = 0;
  final linesToWrite = <String>[];

  // Read all lines first, then iterate
  final lines = await podfile.readAsLines();
  for (final line in lines) {
    final trimmedLine = line.trim();

    if (trimmedLine.startsWith("target 'RunnerTests' do")) {
      print("  Found start of 'RunnerTests' target block at line: ${line.trim()}");
      inTargetBlock = true;
      nestLevel = 1;
      linesSkipped++; // Also skip the starting line
      continue;
    }

    if (inTargetBlock) {
      if (trimmedLine.endsWith(' do')) {
        nestLevel++;
      } else if (trimmedLine == 'end') {
        nestLevel--;
        if (nestLevel == 0) {
          print("  Found end of 'RunnerTests' target block.");
          inTargetBlock = false;
          linesSkipped++; // Skip the ending line
          continue;
        }
      }
      // Still inside the target block or nested block within it
      linesSkipped++;
      continue;
    }

    // If not skipping, add the line to be written
    linesToWrite.add(line);
  }

  if (inTargetBlock) {
    print("Warning: Reached end of file while still inside RunnerTests block. Podfile might be malformed.");
  }

  try {
    // Write the modified content to the temporary file
    await tempPodfile.writeAsString(linesToWrite.join('\n') + '\n'); // Add trailing newline

    // Replace original file with temporary file
    await tempPodfile.rename(podfilePath);
    print('Successfully updated $podfilePath. Skipped $linesSkipped lines.');
  } catch (e) {
    print('Error writing or renaming file: $e');
    // Attempt to clean up temp file
    if (await tempPodfile.exists()) {
      try {
        await tempPodfile.delete();
      } catch (delErr) {
        print("Error deleting temporary file: $delErr");
      }
    }
    exit(1);
  }
}