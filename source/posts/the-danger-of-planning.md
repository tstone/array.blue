---
title:    The Danger of Planning
date:     October 15, 2012 7:52
category: idea
---

When planning is spoken of in a software development context, there are two aspects which it is used for.

The first is a team-communication purpose.  Plans are a tool to centralize the focus of a team.  They give a direction.  Having a plan means a shared understanding about what is being accomplished has been established.  Team communication is important and having a plan puts everyone, "on the same page."  This type of planning is good.  It brings people together and makes sure that work done is headed in the right direction.

The second aspect of planning (or that which people use it for) is quality control.  This aspect of planning is dangerous, particularly to a startup.  The rationale goes something like this:

  > If I have an idea about what I should do before I do it, it must be right.

Perhaps it becomes a bit of a strawman to state it so blatently.  Planning as a means of quality control sounds intuitive at first pass.  Software products are complex things which have many pieces.  If, before all the pieces are built, someone figures out how they all go together, then clearly they will fit together well in the future.

This approach is certainly true in many respects of engineering.  Cars, for example, have a ridiculous amount of planning which goes into them that results in a very complex machine being produced as a result.  To infer that a machine such as a car could come about through any other process is riduclous.

But software isn't a car.  Software tangles it's web into the humane psyche.  It becomes a product of human-computer interaction far more than it spends its time being an engineered product.  It's the irrational and unpredictable nature of human-computer interaction (and the strings attached to it when dealing with the human mind) that makes the predictability of software design almost impossible.

To be clear, by "software design" it is meant the design of the whole system and how users flow through it compared to simply how the code is architected.

Ultimately, "planning" is synonymous with "guessing".  Substituting the word "guess" or "guessing" wherever "plan" and "planning" are used actually allows a good understanding of it's value to take place.

It's reasonable to take a guess at (make a plan of) what should be built.  At least people can share discussion about it.  However it's fairly obvious that spending large amounts of time guessing don't have the return on investment that is worthwhile.

Planning is a team deciding what to do before it's done.  One small change can have a big impact: decide what to do after it's been done.  This, we might call, "evaluation".

If using planning as a means of quality control is bad, using evaluation in it's place is good.  Evaluation works like this:

  > If I examine an idea about what to do after I've done it, I can test if it is right.

It's the testing portion that sets evaluation apart from guessing (planning).

Evaluation can be done on different levels.  The lowest cost is a single developer.  Developers stepping back, and asking themselves, "Does this make sense?" can go really far.  Too often I see a "horse with blinders" effect on developers when they are given plans.  They do exactly what the plan says, whether it makes sense or not.  Even more dangerous, they consider what they did a _success_ because it meets the plan's requirements.

Building something without a full picture of what is being built perhaps sounds like a poor idea.  Hanging around developers for any amount of time it's likely to hear them bemoaning a "lack of requirements".  The thing about taking a guess, doing it, then evaluating it means the risk is run that it might be wrong.  And developers don't like to be wrong.  If there is a plan, it can be pointed to, and developers can say, "Ah ha! See, nothing I did makes sense, BUT, it was in the plan, so it must be righ!  It's _someone else's_ job to make sure if it makes sense or not."  Clearly this isn't the way to a good product.

Further, it should be fairly obvious this method works, if albiet a bit unintuitively.  People often say, "I'll know it when I see it", or, "I wasn't sure what I want until I saw it."  The reason why is because fundamentally it's harder to guess than it is to evaulate.

In case this idea seems entirley extreme, it's worth nothing that agile has such a concept built in called a "spike."  A spike is a small project, done in isolation, designed to be "throw away code".  The idea is that the code is thrown away, but the knowledge is not.

Perhaps instead of writing throw away code, the code is simply written into the product.  It might be thrown away, or it might not.  The knoweldge still remains, and more importantly, the knowledge is shared across the team who can evaluate it together.  There is a word for this too: *refactoring*.

Refactoring, from a business perspective, sounds like a waste.  After all, no new value is being added to the product, so why should it ever be done.  Refactoring is wasteful in the same way servicing the engines of a major truck fleet is wasteful.  True, lubricating engine parts on 100 vehicles doesn't actually deliver value to the customer.  On the flip side, trucks which run well clearly pay for themselves over the long haul.

Developers seem to dislike refacatoring too.  "Why can't we just do it right the first time" is the sentiment that is usually attached.  The problem is, nobody is that lucky to consistently guess what the right thing the first time would have been.  If that weren't the case, Las Vegas would have more winners than it does loosers.  The fact of the matter is, most of the time when it comes to guessing at software development, we're loosing.  If guessing is often loosing, it means a strategy which properly handles managing loss is going to be more effective.  That's evaluation + refactoring.

A higher level phase, above developers evaluating the software on their own, is a small team (2-3 developers) evaluating it together as a group.  Teamwork has come under fire lately.  The _New Yorker_ ran an article or two over the past year on how brainstorming as a large group was bad as studies showed that group think was more likely to happen.  Their conclusion was individuals brainstorming by themselves, then sharing it with a small team, offered the most benefit to everyone.

This approach could certainly be employed.  Developers, as they work through features, are evaluating the state and flow of the product.  At a regular interval (and with small teams) it could be discussed if the product is evolving in a way that makes sense.

Moving up a level, evaluation could be done by people who know nothing of the product.  Joel Sposky calls this, "hallway testing", as in, a random co-worker is grabbed from the hallway, sat in front of a computer, and asked to perform a task with a product they've never seen.  This type of hallway testing seems flippant and ineffective, but typically produces more knowledge than the combined guessing power of the whole development team by creating a portal into that unpreditable entity of the human brain.

The level of testing can continue to move up to more exotic forms, including practices liek A/B testing, user analytics and so forth.

The fundamental premise however remains unchagned.  Testing leads to knowing and is a much better investment than guessing (planning).  Planning adds value to a software project so long as it allows the team to work together, but plans beyond that simply waste time on guesses when energy could be spent on evaluation instead.
