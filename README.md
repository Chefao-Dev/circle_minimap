# Circle Minimap 🗺️
This is a functional class for circle minimaps, done as best as possible without using rendertarget and trying to extract the best possible performance.

![Gravar_2022_07_21_11_31_36_129](https://user-images.githubusercontent.com/85264247/180241332-fc99eeb7-bf47-4433-aeea-04ab56d83b30.gif)
<br>

## How does it work? 🤓
To facilitate the use of those who do not have much knowledge with classes in lua I chose not to use RenderTargets or imageSection, in a simple and direct way the minimap uses a technique of shaders combining a mask with a limited one that can be found in a very raw version following [hud_mask.fx](https://wiki.multitheftauto.com/wiki/Shader_examples)


## Blips
I have in mind that with shaders to apply a clipping effect according to the blips is complicated and I would have to use an image section or even render target, but as the intention is not to be a 100% code for production but only for learning for those who don't have that much knowledge about classes I decided to just remove the blip when the player is far enough away.

![Gravar_2022_07_21_11_46_14_228](https://user-images.githubusercontent.com/85264247/180243323-4f9133b8-4cba-40ee-82c9-5bbbf495a67a.gif)

## Motivation 💕
First of all, remember that this can even be used on a roleplay server but I don't recommend using it for production. this model is produced only for skills demonstration and for those who don't have much or less knowledge in lua classes. If you felt embraced by this system, feel free to contribute and improve the code even more.

![image](https://user-images.githubusercontent.com/85264247/180244771-8cd93b22-dbe3-4bc1-8018-d6a14081b173.png)
