# -*- coding: utf-8 -*-
# Opus 4.8-authored podcast specs (content type #3, Podcasts / Watch - audio half).
# gen_podcasts_wave.py expands these into schema-correct passage(kind=podcast)
# + sentence + comprehension item + gloss rows. Host-monologue style; the audio
# transcript == the joined sentence lines (honesty). audio_ref + duration_ms are
# patched later by gen_podcast_audio.py (Gemini TTS -> R2). PROOF wave = 2 (A1,A2).
PODCASTS = [
 dict(level="A1", k="0101", title="My Morning", theme="daily routines",
   about="A short podcast where the host describes a simple morning routine, practising present-simple 'I' verbs and telling the time from A1.",
   lines=[
     ("Hello, and welcome to the Ratel English podcast.", "'Welcome to' is a friendly way to start a show."),
     ("Today, I talk about my morning.", "'Talk about' means to say things on a topic."),
     ("I wake up at seven o'clock.", "'Wake up' means to stop sleeping; we say a clock time with 'at'."),
     ("I drink coffee and eat some bread.", "'And' joins the two things I do."),
     ("Then I go to work by bus.", "'By bus' tells us how the host travels."),
     ("What do you do in the morning?", "This is a question to you, the listener."),
   ],
   checks=[
     dict(q="What time does the host wake up?", why="Line 3 says 'I wake up at seven o'clock.'",
       opts=[("At seven o'clock", True, "Yes - the host wakes up at seven."),
             ("At eight o'clock", False, "No, the host says seven, not eight."),
             ("At six o'clock", False, "No, it is seven o'clock.")]),
     dict(q="How does the host go to work?", why="Line 5 says 'I go to work by bus.'",
       opts=[("By bus", True, "Correct - the host goes by bus."),
             ("By car", False, "The podcast says by bus, not car."),
             ("On foot", False, "No, the host takes the bus.")]),
   ]),
 dict(level="A2", k="0102", title="A Weekend Trip", theme="travel and free time",
   about="The host tells a short story about last weekend, practising past-simple verbs (went, took, saw) from A2.",
   lines=[
     ("Welcome back to the Ratel English podcast.", "'Welcome back' greets listeners who return."),
     ("Last weekend, I went to the mountains.", "'Went' is the past of 'go'."),
     ("I took an early train on Saturday.", "'Took' is the past of 'take'."),
     ("The weather was cold but sunny.", "'Was' is the past of 'is'; 'but' shows a contrast."),
     ("I walked for three hours and saw a lake.", "'Walked' is a regular past verb; 'saw' is the past of 'see'."),
     ("On Sunday, I came home and felt happy.", "'Came' and 'felt' are irregular past verbs."),
     ("Where did you go last weekend?", "We use 'did' to ask a past-simple question."),
   ],
   checks=[
     dict(q="Where did the host go last weekend?", why="Line 2 says 'I went to the mountains.'",
       opts=[("To the mountains", True, "Yes - the host went to the mountains."),
             ("To the beach", False, "No, it was the mountains."),
             ("To a city", False, "The host went to the mountains, not a city.")]),
     dict(q="What was the weather like?", why="Line 4 says 'The weather was cold but sunny.'",
       opts=[("Cold but sunny", True, "Correct - cold but sunny."),
             ("Warm and rainy", False, "No, it was cold but sunny."),
             ("Hot and windy", False, "The podcast says cold but sunny.")]),
   ]),
]
