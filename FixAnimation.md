# Godot 4 AnimationPlayer "Make Unique" not working; Changing duplicate affects the original; Fix for animations being shared.
Resource

So, in Godot 4 they made AnimationLibraries their own resources. As a side effect, duplicating an AnimationPlayer or a scene containing an AnimationPlayer causes them to be tethered. For example, if I save scene A as scene B, then change the animation in scene B, it will affect scene A's animation. Finding a fix for this that worked was surprisingly rough, and after some trial and error I found a method that worked for me. Figured I'd share in case anyone else is having this issue.

1. On the AnimPlayer you want to duplicate, go to Libraries, and click on Dictionary to reveal the AnimationLibrary.
2. Click on the arrow next to AnimationLibrary, scroll all the way down, and click on save. Name your animation (It'll save as .tres)
3. On another scene with the same (duplicated) AnimationPlayer, delete the AnimationPlayer.
4. Create a new AnimationPlayer, and add a new animation (Doesn't need a name/data, just add a blank one). This will allow you to set the AnimationLibrary in the Dictionary.
5. In your FileSystem interface, duplicate your Anim.tres and rename it.
6. In your new AnimationPlayer, expand the Dictionary, and drag your NewAnim.tres onto the AnimationLibrary in the dictionary. You should now see the animation on the bottom automatically receive the animations from the original.
7. You can now modify the animations on the duplicate without affecting the original. Check to make sure any changes you make aren't affecting the other ones.
