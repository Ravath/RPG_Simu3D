using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace RPG_Simu3D.Core
{

	public delegate void ValueChangedHandler(IValue ival, int newValue, int oldValue);

	/// <summary>
	/// A monitored value. Can have modifiers,
	/// and managed a network of listeners to notice when the value changed.
	/// </summary>
	public interface IValue
	{
		string Name { get; set; }
		int BaseValue { get; }
		int TotalValue { get; }
		IEnumerable<IValue> Modifiers { get; }
		void AddModifier(IValue mod);
		void RemoveModifier(IValue mod);
		/// <summary>
		/// When the value changed.
		/// A assignation to the same value is not a change.
		/// </summary>
		event ValueChangedHandler OnValueChanged;
	}

	/// <summary>
	/// Default IValue implementation.
	/// A int value with a name and potential modifiers.
	/// </summary>
	public class Value : IValue
	{

		#region Events
		public event ValueChangedHandler OnValueChanged;
		#endregion

		#region Members
		private int _baseValue;
		private readonly List<IValue> _modifiers = new List<IValue>();
		#endregion

		#region Properties
		public virtual string Name { get; set; }


		public virtual int BaseValue
		{
			get { return _baseValue; }
			set
			{
				if (value == _baseValue) { return; }
				int old = _baseValue;
				_baseValue = value;
				if (OnValueChanged != null)
				{
					int tot = TotalValue;
					OnValueChanged(this, tot, tot + old - value);
				}
			}
		}

		public virtual int TotalValue
		{
			get
			{
				return _modifiers.Sum(p => p.TotalValue) + BaseValue;
			}
		}
		public IEnumerable<IValue> Modifiers
		{
			get { return _modifiers; }
		}
		#endregion

		#region Init
		public Value()
		{

		}
		public Value(int val)
		{
			BaseValue = val;
		}
		public Value(IValue val)
		{
			BaseValue = val.BaseValue;
			foreach (var item in val.Modifiers)
			{
				AddModifier(item);
			}
		}
		#endregion

		#region Functions
		public virtual void AddModifier(IValue mod)
		{
			_modifiers.Add(mod);
			mod.OnValueChanged += ModifierChanged;
			int modTot = mod.TotalValue;
			if (OnValueChanged != null && modTot != 0)
			{
				int tot = TotalValue;
				OnValueChanged(this, tot, tot - modTot);
			}
		}
		public virtual void RemoveModifier(IValue mod)
		{
			_modifiers.Remove(mod);
			mod.OnValueChanged -= ModifierChanged;
			int modTot = mod.TotalValue;
			if (OnValueChanged != null && modTot != 0)
			{
				int tot = TotalValue;
				OnValueChanged(this, tot, tot + modTot);
			}
		}

		private void ModifierChanged(IValue mod, int newVal, int oldVal)
		{
			if (OnValueChanged != null)
			{
				int tot = TotalValue;
				OnValueChanged(this, tot, tot + oldVal - newVal);
			}
		}

		public override string ToString()
		{
			return string.Format("{0}({1})", BaseValue, TotalValue);
		}
		#endregion
	}

	public abstract class DerivedValue : IValue
	{

		public event ValueChangedHandler OnValueChanged;
		
		#region members
		private readonly HashSet<IValue> _values = new HashSet<IValue>();
		private readonly List<IValue> _modifiers = new List<IValue>();
		#endregion

		#region Properties
		public virtual string Name { get; set; }
		public IEnumerable<IValue> Modifiers { get { return _modifiers; } }

		public int TotalValue { get { return _modifiers.Sum(p => p.TotalValue) + BaseValue; } }
		public abstract int BaseValue { get; } 
		#endregion

		#region Init
		public DerivedValue(params IValue[] vals)
		{
			AddDerivedValue(vals);
		}
		/// <summary>
		/// Add the instance to the valueChanged Event of the values it is calculated from.
		/// </summary>
		/// <param name="vals">Values used for computation of the value.</param>
		protected void AddDerivedValue(params IValue[] vals)
		{
			foreach (IValue v in vals)
			{
				v.OnValueChanged += DerivedValBaseChanged;
				_values.Add(v);
			}
		}
		/// <summary>
		/// Add the instance from the valueChanged Event of the values because it don't use them any more for computation.
		/// </summary>
		/// <param name="vals">Values no more used used for computation of the value.</param>
		protected void RemoveDerivedValue(params IValue[] vals)
		{
			foreach (IValue v in vals)
			{
				v.OnValueChanged -= DerivedValBaseChanged;
				_values.Remove(v);
			}
		} 
		#endregion

		private void DerivedValBaseChanged(IValue ival, int newValue, int oldValue)
		{
			if (OnValueChanged != null)
			{
				int tot = TotalValue;
				int old = tot - newValue + oldValue;
				OnValueChanged(this, tot, old);
			}
		}

		public void AddModifier(IValue mod)
		{
			int tot = TotalValue;
			int modTot = mod.TotalValue;
			_modifiers.Add(mod);
			mod.OnValueChanged += DerivedValBaseChanged;
			if (modTot != 0 && OnValueChanged != null)
			{
				OnValueChanged(this, tot, tot + modTot);
			}
		}

		public void RemoveModifier(IValue mod)
		{
			int tot = TotalValue;
			int modTot = mod.TotalValue;
			_modifiers.Remove(mod);
			mod.OnValueChanged -= DerivedValBaseChanged;
			if (modTot != 0 && OnValueChanged != null)
			{
				OnValueChanged(this, tot, tot - modTot);
			}
		}
	}
	/// <summary>
	/// The base value is the Total value from the source, but the source can be changed.
	/// </summary>
	public class IndirectValue : DerivedValue
	{
		private IValue _iv;
		public IndirectValue(IValue val) : base(val)
		{
			_iv = val;
		}
		/// <summary>
		/// Base indirect value.
		/// </summary>
		public override int BaseValue
		{
			get { return _iv.TotalValue; }
		}
		/// <summary>
		/// Change the source
		/// </summary>
		/// <param name="val"></param>
		public void SetValue(IValue val)
		{
			if (val == _iv) { return; }
			if (_iv != null)
				RemoveDerivedValue(_iv);
			if (val != null)
				AddDerivedValue(val);
			_iv = val;
		}
	}

	/// <summary>
	/// Compute the BaseVaue using the given computation method.
	/// </summary>
	public class ComputedValue : DerivedValue
	{
		private Func<int> _computationMethod;
		public override int BaseValue
		{
			get { return _computationMethod(); }
		}

		public ComputedValue(Func<int> computation, params IValue[] values) : base(values)
		{
			_computationMethod = computation;
		}
	}
}
