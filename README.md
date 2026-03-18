# Office Survivors

A Godot 4 game project.

## Prerequisites

- [Godot 4](https://godotengine.org/download/)
- [Git](https://git-scm.com/)
- [Git LFS](https://git-lfs.com/)

## Setup

1. **Install Git LFS** (required to download binary assets):

   ```bash
   git lfs install
   ```

2. **Clone the repository:**

   ```bash
   git clone https://github.com/zuzing/office-survivors.git
   cd office-survivors
   ```

3. **Pull LFS assets:**

   ```bash
   git lfs pull
   ```

4. **Open the project in Godot 4:**

   Launch Godot 4, click **Import**, and select the `project.godot` file in the cloned directory.

## Git LFS

This project uses [Git Large File Storage (LFS)](https://git-lfs.com/) to manage binary assets such as images, audio, fonts, 3D models, and exported builds. The tracked file types are defined in [`.gitattributes`](.gitattributes).

If you add new binary assets to the project, make sure they match one of the tracked patterns in `.gitattributes`. To track an additional file type, run:

```bash
git lfs track "*.ext"
git add .gitattributes
```