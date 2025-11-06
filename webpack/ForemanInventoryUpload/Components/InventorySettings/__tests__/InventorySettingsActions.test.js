import { getSettings, setSetting } from '../InventorySettingsActions';

describe('Inventory settings actions', () => {
  it('should getSettings', () => {
    const action = getSettings();
    expect(action).toEqual({
      type: 'get-some-type',
      key: 'INVENTORY_SETTINGS',
      url: '/foreman_inventory_upload/settings',
    });
  });

  it('should setSetting hostObfuscation true', () => {
    const dispatch = jest.fn();
    setSetting({
      setting: 'hostObfuscation',
      value: true,
    })(dispatch);

    expect(dispatch).toHaveBeenCalledWith(
      expect.objectContaining({
        type: 'post-some-type',
        key: 'INVENTORY_SETTINGS',
        url: '/foreman_inventory_upload/setting',
        params: {
          setting: 'hostObfuscation',
          value: true,
        },
      })
    );
  });
});
