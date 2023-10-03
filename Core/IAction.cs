using Godot;
using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RPG_Simu3D.Core
{
	public class Target
	{
		public Godot.Vector2 Position;
		public IEnumerable<Token> Tokens;
	}

	public enum ActionRangeType
	{
		// Can only target self.
		SELF,
		// Can only target at natural range.
		CONTACT,
		// Can target at the range of the weapon/tool currently used.
		ATTACK_RANGE,
		// Must have some perceptive sensation on the target, mostly by sight.
		LINE_OF_SIGHT,
		// The target is subject to projectile regulation, even if sighted.
		// It may not forbid the shoot, but only impede it.
		PROJECTILE,
		// Can target anywhere at range, even through walls and stuff.
		// May still need some information on the target, such as the name, or a general direction.
		AT_WILL,
		// Every valid target in the area is affected by the action.
		ALL
	}

	public interface IActionArea
	{
		ActionRangeType RangeType { get; }
		int NumberOfPointsNeeded { get; }
		IEnumerable<Godot.Vector2> GetZone(Godot.Vector2 caster, params Godot.Vector2[] points);
	}

	public interface ITargeting
	{
		/// <summary>
		/// The maximum number of target in one action.
		/// -1 for All targets in the area.
		/// </summary>
		int Number { get; }
		/// <summary>
		/// The area range where to target for the action.
		/// </summary>
		IActionArea Area { get; }
		/// <summary>
		/// Filter the potential targets with more accuracy.
		/// </summary>
		IFilter<Target> Filter { get; }

	}

	public class Action
	{
		/// <summary>
		/// For sorting and priorizing the actions.
		/// </summary>
		public int Category;
		/// <summary>
		/// The area range where to choose targets.
		/// </summary>
		public ITargeting TargetArea { get; }
		/// <summary>
		/// The area range where the action takes effect.
		/// </summary>
		public ITargeting EffectArea { get; }
		/// <summary>
		/// The action to perform on the targets (or available targets in the effect area if any).
		/// </summary>
		/// <param name="targets">Targets of the action.</param>
		/// <returns></returns>
		public delegate ActionResult DoAction(IEnumerable<Token> targets);

	}
	public class ActionResult
	{
		public bool Success;
		public string Log;
	}
}
