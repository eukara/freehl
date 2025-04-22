/*! \brief Shared-Entity: HL HUD Sheet Counter */
/*!QUAKED hlHUDCounter (0 1 0) (-8 -8 -8) (8 8 8)
# OVERVIEW
When active, will display an icon and text at its position that can be seen
by players.

# KEYS
- "targetname" : Name
- "Image" : Path of the material that the game will use for the icon.
- "model"	: If set, will use this (sprite) model instead.
- "Text" : A localised string to display next to it.
- "additive"	: When 1, will force the image to be drawn additive.

# INPUTS
- "Enable" : Enable the entity.
- "Disable" : Disable the entity.
- "Toggle" : Toggles between enabled/disabled states.
- "SetValue" : Overrides the current counter value.
- "Increment" : Increment by the desired amount.
- "Decrement" : Decrement by the desired amount.

# TRIVIA
This entity was introduced in Nuclide in February of 2025.

@ingroup sharedentity
@ingroup pointentity
*/
class
hlHUDCounter:ncPointTrigger
{
public:
	void hlHUDCounter(void);

#ifdef SERVER
	virtual void SpawnKey(string,string);
	virtual void Save(float);
	virtual void Restore(string,string);
	virtual void Input(entity,string,string);
	virtual void Trigger(entity, triggermode_t);

	virtual void EvaluateEntity(void);
	virtual float SendEntity(entity,float);
#endif

#ifdef CLIENT
	virtual void ReceiveEntity(float, float);
	virtual void postdraw(void);
#endif

private:
	PREDICTED_INT(m_counterValue)
	PREDICTED_STRING(m_strIcon)
	PREDICTED_STRING(m_strText)
	PREDICTED_BOOL(m_bEnabled)
	PREDICTED_BOOL(m_bAdditive)
	PREDICTED_VECTOR(m_vecPosXY)
	PREDICTED_VECTOR_N(colormod)

#ifdef SERVER
	int m_teamScore;
#endif
};
