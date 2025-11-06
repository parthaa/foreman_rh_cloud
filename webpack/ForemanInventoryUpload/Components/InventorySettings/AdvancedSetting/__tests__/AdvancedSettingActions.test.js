import { handleToggle } from '../AdvancedSettingActions';

describe('AdvancedSetting actions', () => {
  it('should handleToggle', () => {
    const dispatch = jest.fn();
    handleToggle('autoUploadEnabled', false)(dispatch);

    expect(dispatch).toHaveBeenCalledWith(
      expect.objectContaining({
        type: 'post-some-type',
        key: 'INVENTORY_SETTINGS',
        url: '/foreman_inventory_upload/setting',
        params: {
          setting: 'autoUploadEnabled',
          value: true,
        },
      })
    );
  });
});
