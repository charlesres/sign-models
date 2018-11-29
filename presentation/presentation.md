% Behavioral Evolution Rodent Model: Bat Rats™
% Charly Resendiz (`charly.resendiz@northwestern.edu`)
% Nov 7, 2018

## The Goal

> - To demonstrate that selective breeding can influence path finding strategies
> - To show multiple phases to evolution, especially with behaviour
> - The model does not simulate a naturally occuring phenomenon
>   - Rats, but with the ability to read signs

## Behavioral Evolution Model

![Searching Model](VarietyofThings.png){height=60%}\

## Background : Behavioral Genetics

A field of scientific research that uses genetic methods to investigate the nature and origins of individual differences in behavior. This is commonly seen with :

> - Selective Breeding
> - Domestication
> - Natural Selection
>   - Stealth
>   - Construction
>   - Navigation

## Collaborative Traits (Helpful or Foolish)

> - Does not guarantee passing on an organism's genes
> - Behavior can help other organisms
> - Straightforward actions

## Overview

You begin with 15 rodents, outside a specified radius, with the food huddled in the center

![Initializing the Environment](FoodInTheCenter.png){width=50%}\

## Variables

> - Likelihood to lie (units : %)
> - Likelihood to drop a sign (units : %)
> - Range of possible sign angle error (units : degrees)
> - *Maximum Random Turning Angle* (MRTA) (unit : degrees)
> - Energy (not configurable)
> - Topology

## Color Sheet

### Mice Colors

> - Grey (Searching)
> - Orange (Noticed Sign)
> - Green (Influenced by Sign)
> - White (Ate)

### Sign Colors

> - Yellow (Honest)
> - Red (Intentionally Misleading)

## Plots and Pens

> - Pen (Visualize a rat's maximum random turning angle)
> - Range's Maximum Turning Angle
> - Probability Range

## Observations

Depending on the inital configurations, the rats pass on certain behaviors

> - More willing to lie/cooperate
> - More accurate signs or no signs at all
> - Having higher or lower maximum turning angle

## Demo

<!--
  ## FAQ

> - Does it represent a phenomenon? No, I figured mice mazes would be interestngi
> - How does this simulate behavior genetics? Through passing on the likelihood of
    acting a certain manner
> - Do the plots help with demonstrating the point of generational inheritance?
    I would say yes, because we can track the difference in each generation -->

## Possible Extensions

> - Adding vision
> - Adding probability of following sign
> - User-defined inital energy
> - Pre-defined behaviors as an option
