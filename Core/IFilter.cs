using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RPG_Simu3D.Core
{
	public enum ObjectCategory
	{
		PLACE = 0, OBJECT = 1, CHARACTER = 2,
		NONE = 3 // For targeting nothing
	}

	public interface IFilter<C> where C : Target
	{
		IEnumerable<C> Filter(IEnumerable<C> cs);
	}

	public class DefaultFilter : IFilter<Target>
	{
		/// <summary>
		/// The nature of the target for this action.
		/// When NONE, the action doesn't need any target,
		/// and can be done directly, such as skill rools.
		/// Don't confuse with actions done exclusively upon oneself.
		/// </summary>
		public ObjectCategory TargetType { get; }

		public DefaultFilter(ObjectCategory targetType)
		{
			this.TargetType = targetType;
		}

		public IEnumerable<Target> Filter(IEnumerable<Target> cs)
		{
			if (TargetType == ObjectCategory.PLACE)
			{
				foreach (var item in cs)
				{
					yield return item;
				}
			}
			else
			{
				foreach (Target tile in cs)
				{
					foreach (Token token in tile.Tokens)
					{
						if (token.ObjectType == TargetType)
						{
							Target t = new Target()
							{
								Position = tile.Position,
								Tokens = new List<Token>() { token }
							};
							yield return t;
						}
					}
				}
			}
		}
	}
}
